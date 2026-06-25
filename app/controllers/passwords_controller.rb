class PasswordsController < ApplicationController
  # No authentication required for these actions
  skip_before_action :require_user, raise: false

  def setup
    @token = params[:token]
    @user = Usuario.find_by(setup_token: @token)
    validate_setup_token!
  end

  def validate_setup_token!
    return render_token_error("Link inválido") if @user.nil?
    return render_token_error("Este link já foi utilizado. Faça login normalmente") if @user.setup_token_used?
    render_token_error("Link expirado. Solicite um novo e-mail de cadastro ao administrador") if setup_token_expired?
  end

  def setup_token_expired?
    @user.setup_token_sent_at.nil? || @user.setup_token_sent_at < 24.hours.ago
  end

  def render_token_error(msg)
    flash.now[:alert] = msg
    render :setup_error
  end

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

  def forgot
    # Render forgot page
  end

  def forgot_send
    email = params[:email]&.strip
    return render_forgot_blank_email if email.blank?
    return render_forgot_invalid_email(email) unless email.include?("@")

    user = Usuario.find_by(email: email)
    user&.generate_reset_token!

    flash[:notice] = "Se este e-mail estiver cadastrado, você receberá as instruções em breve"
    redirect_to login_path
  end

  def render_forgot_blank_email
    flash.now[:alert] = "Preencha o campo de e-mail"
    render :forgot, status: :unprocessable_entity
  end

  def render_forgot_invalid_email(email)
    flash.now[:alert] = "E-mail inválido"
    render :forgot, status: :unprocessable_entity
  end

  def reset
    @token = params[:token]
    @user = Usuario.find_by(reset_token: @token)
    validate_reset_token!
  end

  def validate_reset_token!
    return render_token_error("Link inválido") if @user.nil?
    return render_token_error("Este link já foi utilizado. Solicite uma nova redefinição de senha") if @user.reset_token_used?
    render_token_error("Link expirado. Solicite uma nova redefinição de senha") if reset_token_expired?
  end

  def reset_token_expired?
    @user.reset_token_sent_at.nil? || @user.reset_token_sent_at < 24.hours.ago
  end

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

  def load_user_by_token(field)
    @token = params[:token]
    @user = Usuario.find_by(field => @token)
  end

  def handle_invalid_link
    flash.now[:alert] = "Link inválido"
    redirect_to login_path
    true
  end

  def handle_missing_passwords(action)
    return false unless params[:password].blank? || params[:password_confirmation].blank?

    flash.now[:alert] = "Preencha todos os campos obrigatórios"
    render action
    true
  end

  def assign_passwords
    @user.validating_password_rules = true
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
  end

  def finalize_setup
    @user.setup_token_used = true
    @user.ativo = true
    @user.save!
    session[:usuario_id] = @user.id
    flash[:notice] = "Senha definida com sucesso. Bem-vindo!"
    redirect_to avaliacoes_path
  end

  def handle_invalid_password(action)
    flash.now[:alert] = @user.errors[:password].first
    render action, status: :unprocessable_entity
  end

  def handle_expired_reset_link
    if @user.reset_token_sent_at.nil? || @user.reset_token_sent_at < 24.hours.ago
      flash.now[:alert] = "Link expirado. Solicite uma nova redefinição de senha"
      render :reset, status: :unprocessable_entity
      return true
    end
    false
  end

  def handle_same_password
    if @user.authenticate(params[:password])
      flash.now[:alert] = "A nova senha não pode ser igual à senha anterior"
      render :reset, status: :unprocessable_entity
      return true
    end
    false
  end

  def finalize_reset
    @user.reset_token_used = true
    @user.save!
    flash[:notice] = "Senha redefinida com sucesso. Faça login com sua nova senha"
    redirect_to login_path
  end
end
