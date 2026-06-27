class PasswordsController < ApplicationController
  # No authentication required for these actions
  skip_before_action :require_user, raise: false

  # Renderiza a página de configuração inicial da senha para um usuário novo.
  #
  # = Parâmetros:
  # * +params[:token]+ - O token de setup enviado por e-mail (String).
  #
  # = Retorno:
  # * +nil+ ou renderiza página de erro caso token seja inválido/expirado.
  #
  # = Efeitos Colaterais:
  # * Define as variáveis de instância +@token+ e +@user+.
  def setup
    @token = params[:token]
    @user = Usuario.find_by(setup_token: @token)
    validate_setup_token!
  end

  # Valida se o token de setup é válido, não utilizado e não expirado.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * +nil+ se válido, ou renderização da tela de erro em caso de problemas.
  #
  # = Efeitos Colaterais:
  # * Pode definir alerta no +flash.now+ e renderizar a view +:setup_error+.
  def validate_setup_token!
    return render_token_error("Link inválido") if @user.nil?
    return render_token_error("Este link já foi utilizado. Faça login normalmente") if @user.setup_token_used?
    render_token_error("Link expirado. Solicite um novo e-mail de cadastro ao administrador") if setup_token_expired?
  end

  # Verifica se o link de setup do usuário expirou (limite de 24 horas).
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Boolean (+true+ se expirado, +false+ caso contrário).
  #
  # = Efeitos Colaterais:
  # * Nenhum.
  def setup_token_expired?
    @user.setup_token_sent_at.nil? || @user.setup_token_sent_at < 24.hours.ago
  end

  # Renderiza a página de erro com a mensagem de token inválido.
  #
  # = Parâmetros:
  # * +msg+ - Mensagem explicativa do erro (String).
  #
  # = Retorno:
  # * Renderiza o template +:setup_error+.
  #
  # = Efeitos Colaterais:
  # * Adiciona alerta ao +flash.now+.
  def render_token_error(msg)
    flash.now[:alert] = msg
    render :setup_error
  end

  # Processa o envio da definição de senha inicial.
  #
  # = Parâmetros:
  # * +params[:token]+ - Token de configuração (String).
  # * +params[:password]+ - Senha desejada (String).
  # * +params[:password_confirmation]+ - Confirmação da senha (String).
  #
  # = Retorno:
  # * Redirecionamento ou renderização com erro de validação.
  #
  # = Efeitos Colaterais:
  # * Atualiza e salva a senha do usuário no banco de dados e inicia sua sessão.
  def setup_update
    return if handle_invalid_link unless load_user_by_token(:setup_token)
    return if handle_missing_passwords(:setup)

    assign_passwords

    if @user.valid?
      finalize_setup
    else
      handle_invalid_password(:setup)
    end
  end

  # Renderiza a página de solicitação de recuperação de senha ("Esqueci minha senha").
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Renderiza a view correspondente.
  #
  # = Efeitos Colaterais:
  # * Nenhum.
  def forgot
    # Render forgot page
  end

  # Processa o envio do e-mail para geração do link de redefinição de senha.
  #
  # = Parâmetros:
  # * +params[:email]+ - O e-mail do usuário que deseja redefinir a senha (String).
  #
  # = Retorno:
  # * Redirecionamento para a tela de login ou renderiza erro caso e-mail seja inválido.
  #
  # = Efeitos Colaterais:
  # * Gera e salva token de reset no usuário e envia e-mail com instruções se e-mail estiver cadastrado.
  def forgot_send
    email = params[:email]&.strip
    return render_forgot_blank_email if email.blank?
    return render_forgot_invalid_email(email) unless email.include?("@")

    user = Usuario.find_by(email: email)
    user&.generate_reset_token!

    flash[:notice] = "Se este e-mail estiver cadastrado, você receberá as instruções em breve"
    redirect_to login_path
  end

  # Exibe erro caso o campo de e-mail na recuperação esteja em branco.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Renderiza a view +:forgot+ com status +:unprocessable_entity+.
  #
  # = Efeitos Colaterais:
  # * Adiciona alerta ao +flash.now+.
  def render_forgot_blank_email
    flash.now[:alert] = "Preencha o campo de e-mail"
    render :forgot, status: :unprocessable_entity
  end

  # Exibe erro caso o formato do e-mail informado seja inválido.
  #
  # = Parâmetros:
  # * +email+ - E-mail inválido digitado (String).
  #
  # = Retorno:
  # * Renderiza a view +:forgot+ com status +:unprocessable_entity+.
  #
  # = Efeitos Colaterais:
  # * Adiciona alerta ao +flash.now+.
  def render_forgot_invalid_email(email)
    flash.now[:alert] = "E-mail inválido"
    render :forgot, status: :unprocessable_entity
  end

  # Renderiza a tela para o usuário definir uma nova senha após clicar no link do e-mail.
  #
  # = Parâmetros:
  # * +params[:token]+ - O token de redefinição de senha (String).
  #
  # = Retorno:
  # * +nil+ ou renderiza tela de erro caso o link seja inválido/expirado.
  #
  # = Efeitos Colaterais:
  # * Define as variáveis de instância +@token+ e +@user+.
  def reset
    @token = params[:token]
    @user = Usuario.find_by(reset_token: @token)
    validate_reset_token!
  end

  # Valida se o token de reset é válido, não utilizado e dentro do prazo de expiração.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * +nil+ se válido, ou renderiza tela de erro em caso contrário.
  #
  # = Efeitos Colaterais:
  # * Pode definir alerta no +flash.now+ e renderizar a view de erro.
  def validate_reset_token!
    return render_token_error("Link inválido") if @user.nil?
    return render_token_error("Este link já foi utilizado. Solicite uma nova redefinição de senha") if @user.reset_token_used?
    render_token_error("Link expirado. Solicite uma nova redefinição de senha") if reset_token_expired?
  end

  # Verifica se o link de redefinição de senha do usuário expirou (limite de 24 horas).
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Boolean (+true+ se expirado, +false+ caso contrário).
  #
  # = Efeitos Colaterais:
  # * Nenhum.
  def reset_token_expired?
    @user.reset_token_sent_at.nil? || @user.reset_token_sent_at < 24.hours.ago
  end

  # Processa e valida a atualização de redefinição da senha do usuário.
  #
  # = Parâmetros:
  # * +params[:token]+ - Token de reset (String).
  # * +params[:password]+ - Nova senha (String).
  # * +params[:password_confirmation]+ - Confirmação da nova senha (String).
  #
  # = Retorno:
  # * Redirecionamento ou renderização com mensagens de erro.
  #
  # = Efeitos Colaterais:
  # * Atualiza e salva a senha do usuário no banco de dados.
  def reset_update
    return if handle_invalid_link unless load_user_by_token(:reset_token)
    return if handle_expired_reset_link
    return if handle_missing_passwords(:reset)
    return if handle_same_password

    assign_passwords

    if @user.valid?
      finalize_reset
    else
      handle_invalid_password(:reset)
    end
  end

  private

  # Carrega o usuário utilizando o token contido na requisição baseado no campo indicado.
  #
  # = Parâmetros:
  # * +field+ - Símbolo indicando se busca por +:setup_token+ ou +:reset_token+ (Symbol).
  #
  # = Retorno:
  # * Objeto +Usuario+ encontrado ou +nil+.
  #
  # = Efeitos Colaterais:
  # * Preenche as variáveis de instância +@token+ e +@user+.
  def load_user_by_token(field)
    @token = params[:token]
    @user = Usuario.find_by(field => @token)
  end

  # Trata o caso em que o link fornecido é inválido.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Sempre retorna +true+.
  #
  # = Efeitos Colaterais:
  # * Define alerta de link inválido no +flash.now+ e redireciona para a tela de login.
  def handle_invalid_link
    flash.now[:alert] = "Link inválido"
    redirect_to login_path
    true
  end

  # Verifica e trata se algum campo de senha ou confirmação de senha foi enviado em branco.
  #
  # = Parâmetros:
  # * +action+ - Símbolo representando a view a ser renderizada em caso de erro (Symbol).
  #
  # = Retorno:
  # * Boolean (+true+ se algum campo estiver em branco, +false+ caso contrário).
  #
  # = Efeitos Colaterais:
  # * Se houver erro, adiciona alerta no +flash.now+ e renderiza a view do +action+ informado.
  def handle_missing_passwords(action)
    return false unless params[:password].blank? || params[:password_confirmation].blank?

    flash.now[:alert] = "Preencha todos os campos obrigatórios"
    render action
    true
  end

  # Atribui a nova senha e sua confirmação ao usuário, habilitando validação de regras de força da senha.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * +nil+
  #
  # = Efeitos Colaterais:
  # * Altera os atributos +validating_password_rules+, +password+ e +password_confirmation+ do objeto +@user+.
  def assign_passwords
    @user.validating_password_rules = true
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
  end

  # Finaliza o processo de setup de senha marcando o token como utilizado, ativando a conta e logando o usuário.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Redirecionamento para a página de avaliações.
  #
  # = Efeitos Colaterais:
  # * Salva o usuário com +setup_token_used = true+ e +ativo = true+, armazena o ID do usuário na sessão e define mensagem de boas-vindas no +flash+.
  def finalize_setup
    @user.setup_token_used = true
    @user.ativo = true
    @user.save!
    session[:usuario_id] = @user.id
    flash[:notice] = "Senha definida com sucesso. Bem-vindo!"
    redirect_to avaliacoes_path
  end

  # Renderiza a tela de ação informada adicionando o erro de validação da senha.
  #
  # = Parâmetros:
  # * +action+ - Símbolo da view a ser renderizada (Symbol).
  #
  # = Retorno:
  # * Renderiza a view com status +:unprocessable_entity+.
  #
  # = Efeitos Colaterais:
  # * Adiciona o erro de validação de senha ao +flash.now+.
  def handle_invalid_password(action)
    flash.now[:alert] = @user.errors[:password].first
    render action, status: :unprocessable_entity
  end

  # Verifica e trata se o link de redefinição de senha está expirado no momento da atualização.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Boolean (+true+ se estiver expirado, +false+ caso contrário).
  #
  # = Efeitos Colaterais:
  # * Se expirado, define alerta no +flash.now+ e renderiza a view +:reset+.
  def handle_expired_reset_link
    if @user.reset_token_sent_at.nil? || @user.reset_token_sent_at < 24.hours.ago
      flash.now[:alert] = "Link expirado. Solicite uma nova redefinição de senha"
      render :reset, status: :unprocessable_entity
      return true
    end
    false
  end

  # Verifica se a nova senha escolhida é idêntica à senha antiga cadastrada.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Boolean (+true+ se for a mesma senha, +false+ caso contrário).
  #
  # = Efeitos Colaterais:
  # * Se for igual, define alerta no +flash.now+ e renderiza a view +:reset+.
  def handle_same_password
    if @user.authenticate(params[:password])
      flash.now[:alert] = "A nova senha não pode ser igual à senha anterior"
      render :reset, status: :unprocessable_entity
      return true
    end
    false
  end

  # Conclui a redefinição de senha marcando o token de reset como utilizado e salvando as alterações.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Redirecionamento para a página de login.
  #
  # = Efeitos Colaterais:
  # * Salva o usuário marcando +reset_token_used = true+ e define mensagem de sucesso no +flash+.
  def finalize_reset
    @user.reset_token_used = true
    @user.save!
    flash[:notice] = "Senha redefinida com sucesso. Faça login com sua nova senha"
    redirect_to login_path
  end
end
