class SessionsController < ApplicationController
  # Renderiza a página de login se o usuário não estiver autenticado, ou redireciona-o caso contrário.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * +nil+ ou redirecionamento se o usuário já estiver logado.
  #
  # = Efeitos Colaterais:
  # * Redireciona o usuário logado para o painel apropriado (admin ou avaliações).
  def new
    return unless logged_in?

    if current_user.perfil == "administrador"
      redirect_to admin_dashboard_path
    else
      redirect_to avaliacoes_path
    end
  end

  # Processa a tentativa de login autenticando as credenciais fornecidas.
  #
  # = Parâmetros:
  # * +params[:email]+ - E-mail ou matrícula digitados pelo usuário (String).
  # * +params[:password]+ - Senha digitada pelo usuário (String).
  #
  # = Retorno:
  # * Renderização de template de login em caso de falha, ou redirecionamento em caso de sucesso.
  #
  # = Efeitos Colaterais:
  # * Pode definir mensagens de erro no +flash+ ou estabelecer uma sessão de usuário em caso de sucesso.
  def create
    credencial = params[:email]&.strip
    senha = params[:password]

    return render_missing_fields if credencial.blank? || senha.blank?

    authenticate_and_login(credencial, senha)
  end

  # Destrói a sessão atual do usuário (logout).
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Redirecionamento para a página de login.
  #
  # = Efeitos Colaterais:
  # * Define +session[:usuario_id]+ como +nil+ e gera mensagem de notificação de saída no +flash+.
  def destroy
    session[:usuario_id] = nil
    flash[:notice] = "Você saiu do sistema com sucesso."
    redirect_to login_path
  end

  private

  # Método auxiliar para encapsular o fluxo de autenticação e validação do estado do usuário.
  #
  # = Parâmetros:
  # * +credencial+ - E-mail ou matrícula (String).
  # * +senha+ - Senha do usuário (String).
  #
  # = Retorno:
  # * Redirecionamento ou renderização dependendo do resultado da autenticação.
  #
  # = Efeitos Colaterais:
  # * Cria sessão ou define erros no +flash+.
  def authenticate_and_login(credencial, senha)
    usuario = find_usuario(credencial)
    return handle_invalid_credentials(credencial) unless usuario
    return handle_pending_setup if pending_setup?(usuario)
    return handle_authentication_failure(credencial) unless usuario.authenticate(senha)
    return handle_inactive_user unless usuario.ativo?

    log_in_user(usuario)
  end

  # Exibe erro caso campos obrigatórios de login não sejam preenchidos.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Renderiza a view de login com status +:unprocessable_entity+.
  #
  # = Efeitos Colaterais:
  # * Adiciona alerta ao +flash.now+.
  def render_missing_fields
    flash.now[:alert] = "Preencha todos os campos obrigatórios"
    render :new, status: :unprocessable_entity
  end

  # Busca usuário por e-mail ou matrícula.
  #
  # = Parâmetros:
  # * +credencial+ - E-mail ou matrícula (String).
  #
  # = Retorno:
  # * Objeto +Usuario+ se encontrado, ou +nil+.
  #
  # = Efeitos Colaterais:
  # * Nenhum.
  def find_usuario(credencial)
    Usuario.find_by(email: credencial) || Usuario.find_by(matricula: credencial)
  end

  # Verifica se o cadastro do usuário ainda precisa de configuração de senha inicial.
  #
  # = Parâmetros:
  # * +usuario+ - Instância de +Usuario+.
  #
  # = Retorno:
  # * Boolean indicando se o cadastro está pendente (+true+) ou concluído (+false+).
  #
  # = Efeitos Colaterais:
  # * Nenhum.
  def pending_setup?(usuario)
    usuario.senha_hash.blank? || (usuario.setup_token.present? && !usuario.setup_token_used?)
  end

  # Trata o caso em que o setup inicial do usuário está pendente.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Renderiza a view de login com status +:unprocessable_entity+.
  #
  # = Efeitos Colaterais:
  # * Adiciona alerta ao +flash.now+.
  def handle_pending_setup
    flash.now[:alert] = "Cadastro pendente: Verifique seu e-mail para definir sua senha de acesso."
    render :new, status: :unprocessable_entity
  end

  # Trata o fluxo caso o usuário/credencial não exista no banco de dados.
  #
  # = Parâmetros:
  # * +credencial+ - E-mail ou matrícula testada (String).
  #
  # = Retorno:
  # * Renderiza a view de login com status +:unprocessable_entity+.
  #
  # = Efeitos Colaterais:
  # * Adiciona alerta de erro específico ao +flash.now+ baseado no tipo de credencial.
  def handle_invalid_credentials(credencial)
    if credencial.match?(/^\d+$/)
      flash.now[:alert] = "Matrícula ou senha inválidos"
    elsif !credencial.include?("@")
      flash.now[:alert] = "E-mail inválido"
    else
      flash.now[:alert] = "E-mail ou senha inválidos"
    end
    render :new, status: :unprocessable_entity
  end

  # Trata falha na validação de senha de um usuário existente.
  #
  # = Parâmetros:
  # * +credencial+ - E-mail ou matrícula (String).
  #
  # = Retorno:
  # * Renderiza a view de login com status +:unprocessable_entity+.
  #
  # = Efeitos Colaterais:
  # * Define mensagem genérica de erro no +flash.now+.
  def handle_authentication_failure(credencial)
    if credencial.match?(/^\d+$/)
      flash.now[:alert] = "Matrícula ou senha inválidos"
    else
      flash.now[:alert] = "E-mail ou senha inválidos"
    end
    render :new, status: :unprocessable_entity
  end

  # Trata a tentativa de autenticação por um usuário que está marcado como inativo.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Renderiza a view de login com status +:unprocessable_entity+.
  #
  # = Efeitos Colaterais:
  # * Adiciona mensagem de usuário inativo ao +flash.now+.
  def handle_inactive_user
    flash.now[:alert] = "Usuário inativo. Entre em contato com o administrador"
    render :new, status: :unprocessable_entity
  end

  # Efetiva o login salvando o ID do usuário na sessão e redirecionando.
  #
  # = Parâmetros:
  # * +usuario+ - Objeto +Usuario+ autenticado.
  #
  # = Retorno:
  # * Redirecionamento de rota.
  #
  # = Efeitos Colaterais:
  # * Grava +session[:usuario_id]+ e define mensagem de boas-vindas no +flash+.
  def log_in_user(usuario)
    session[:usuario_id] = usuario.id
    flash[:notice] = "Bem-vindo, #{usuario.nome}!"
    if usuario.perfil == "administrador"
      redirect_to admin_dashboard_path
    else
      redirect_to avaliacoes_path
    end
  end
end
