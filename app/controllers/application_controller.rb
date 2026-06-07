class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= Usuario.find_by(id: session[:usuario_id]) if session[:usuario_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_user
    unless logged_in?
      flash[:alert] = "Você precisa estar logado para acessar esta página."
      redirect_to login_path
    end
  end

  def require_admin
    unless logged_in? && current_user.perfil == 'administrador'
      flash[:alert] = "Acesso negado. Esta área é restrita para administradores."
      redirect_to root_path
    end
  end
end
