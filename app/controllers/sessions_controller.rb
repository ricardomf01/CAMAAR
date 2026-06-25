class SessionsController < ApplicationController
  def new
    return unless logged_in?

    if current_user.perfil == "administrador"
      redirect_to admin_dashboard_path
    else
      redirect_to avaliacoes_path
    end
  end

  def create
    credencial = params[:email]&.strip
    senha = params[:password]

    return render_missing_fields if credencial.blank? || senha.blank?

    authenticate_and_login(credencial, senha)
  end

  def destroy
    session[:usuario_id] = nil
    flash[:notice] = "Você saiu do sistema com sucesso."
    redirect_to login_path
  end

  private

  def authenticate_and_login(credencial, senha)
    usuario = find_usuario(credencial)
    return handle_invalid_credentials(credencial) unless usuario
    return handle_pending_setup if pending_setup?(usuario)
    return handle_authentication_failure(credencial) unless usuario.authenticate(senha)
    return handle_inactive_user unless usuario.ativo?

    log_in_user(usuario)
  end

  def render_missing_fields
    flash.now[:alert] = "Preencha todos os campos obrigatórios"
    render :new, status: :unprocessable_entity
  end

  def find_usuario(credencial)
    Usuario.find_by(email: credencial) || Usuario.find_by(matricula: credencial)
  end

  def pending_setup?(usuario)
    usuario.senha_hash.blank? || (usuario.setup_token.present? && !usuario.setup_token_used?)
  end

  def handle_pending_setup
    flash.now[:alert] = "Cadastro pendente: Verifique seu e-mail para definir sua senha de acesso."
    render :new, status: :unprocessable_entity
  end

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

  def handle_authentication_failure(credencial)
    if credencial.match?(/^\d+$/)
      flash.now[:alert] = "Matrícula ou senha inválidos"
    else
      flash.now[:alert] = "E-mail ou senha inválidos"
    end
    render :new, status: :unprocessable_entity
  end

  def handle_inactive_user
    flash.now[:alert] = "Usuário inativo. Entre em contato com o administrador"
    render :new, status: :unprocessable_entity
  end

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
