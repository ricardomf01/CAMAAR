class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  before_action :setup_test_session, if: -> { Rails.env.test? && Thread.current[:test_usuario_id] }

  private

  def setup_test_session
    session[:usuario_id] = Thread.current[:test_usuario_id]
  end

  def current_user
    @current_user ||= Usuario.find_by(id: session[:usuario_id]) if session[:usuario_id]
  end

  def logged_in?
    current_user.present?
  end
end
