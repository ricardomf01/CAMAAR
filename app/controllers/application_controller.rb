class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  before_action :setup_test_session, if: -> { Rails.env.test? && Thread.current[:test_usuario_id] }

  private

  # Configura a sessão de teste a partir da thread atual.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Integer representando o ID do usuário na sessão ou nil.
  #
  # = Efeitos Colaterais:
  # * Define a chave +:usuario_id+ no hash da sessão.
  def setup_test_session
    session[:usuario_id] = Thread.current[:test_usuario_id]
  end

  # Recupera o usuário atualmente autenticado a partir do ID salvo na sessão.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Objeto +Usuario+ se autenticado, ou +nil+ caso contrário.
  #
  # = Efeitos Colaterais:
  # * Define a variável de instância +@current_user+.
  def current_user
    @current_user ||= Usuario.find_by(id: session[:usuario_id]) if session[:usuario_id]
  end

  # Verifica se existe um usuário autenticado na sessão.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * Boolean (+true+ se logado, +false+ caso contrário).
  #
  # = Efeitos Colaterais:
  # * Nenhum.
  def logged_in?
    current_user.present?
  end

  # Filtro/before_action para exigir que o usuário esteja autenticado.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * +nil+ se já estiver logado, ou redirecionamento em caso contrário.
  #
  # = Efeitos Colaterais:
  # * Define uma mensagem de alerta no +flash+ e redireciona para a tela de login se não estiver logado.
  def require_user
    unless logged_in?
      flash[:alert] = "Você precisa estar logado para acessar esta página."
      redirect_to login_path
    end
  end

  # Filtro/before_action para exigir que o usuário logado seja um administrador.
  #
  # = Parâmetros:
  # * Nenhum.
  #
  # = Retorno:
  # * +nil+ se o usuário for administrador, ou redirecionamento em caso contrário.
  #
  # = Efeitos Colaterais:
  # * Define uma mensagem de alerta no +flash+ e redireciona para a raiz (+root_path+) se não for administrador.
  def require_admin
    unless logged_in? && current_user.perfil == "administrador"
      flash[:alert] = "Acesso negado. Esta área é restrita para administradores."
      redirect_to root_path
    end
  end
end
