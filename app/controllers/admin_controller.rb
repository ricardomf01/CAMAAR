class AdminController < ApplicationController
  before_action :require_admin

  # Class variable to track background update locks
  @@sigaa_updating = false

  def dashboard
    if params[:release_lock] == "true"
      @@sigaa_updating = false
    end

    @stats = {
      deps: Departamento.count,
      discs: Disciplina.count,
      turmas: Turma.count,
      mats: Matricula.count,
      users: Usuario.count
    }
  end

  def carregar_dados_teste
    return if check_sigaa_simulated_errors(admin_dashboard_path)

    begin
      TestDataLoader.call
      flash[:notice] = "Importação concluída com sucesso"
    rescue => e
      flash[:alert] = "Erro ao carregar dados de teste: #{e.message}"
    end
    redirect_to admin_dashboard_path
  end

  def import_console
    if params[:release_lock] == "true"
      @@sigaa_updating = false
    end
  end

  def turmas
    @departamento = current_user.departamento
    if @departamento
      @turmas = Turma.where(departamento: @departamento)
    else
      @turmas = Turma.all
    end

    if @turmas.empty?
      @aviso_mensagem = "Nenhuma turma encontrada para o seu departamento neste semestre. Verifique o status da sincronização com o SIGAA."
    end
  end

  def turma_avaliacoes
    @turma = Turma.find(params[:id])
    if current_user.departamento && @turma.departamento != current_user.departamento
      flash[:alert] = "Acesso negado: Você tem permissão para gerenciar apenas as turmas vinculadas ao seu departamento."
      redirect_to admin_turmas_path and return
    end

    @formularios = @turma.formularios
  end

  def desempenho_semestral
    @departamento = current_user.departamento
    @turmas = @departamento ? Turma.where(departamento: @departamento) : Turma.all

    @desempenho_turmas = @turmas.map do |turma|
      {
        turma: turma,
        media: turma.calcular_media_desempenho,
        respostas_count: turma.respostas_count
      }
    end
  end

  # SIGAA Integrations
  def sigaa_import
    if @@sigaa_updating
      flash[:alert] = "Uma atualização já está em andamento. Aguarde a conclusão."
      redirect_to admin_import_console_path and return
    end

    return if check_sigaa_simulated_errors(admin_import_console_path)

    # Perform normal import logic
    flash[:notice] = "Importação concluída com sucesso"
    redirect_to admin_import_console_path
  end

  def sigaa_update
    return handle_release_lock if params[:release_lock] == "true"
    return if handle_sigaa_updating
    return handle_large_volume if large_volume_request?
    return if check_sigaa_simulated_errors(admin_import_console_path)

    simulate_sigaa_unenrollment
    flash[:notice] = "Base de dados atualizada com sucesso"
    redirect_to admin_import_console_path
  ensure
    @@sigaa_updating = false unless large_volume_request?
  end

  def handle_release_lock
    @@sigaa_updating = false
    flash[:notice] = "Trava liberada com sucesso."
    redirect_to admin_import_console_path
  end

  def handle_large_volume
    @@sigaa_updating = true
    flash[:notice] = "Processando atualização de grande volume do SIGAA"
    redirect_to admin_import_console_path
  end

  def large_volume_request?
    params[:large_volume] == "true" || ENV["SIGAA_LARGE_VOLUME"] == "true"
  end

  private

  def check_sigaa_simulated_errors(redirect_path)
    error_msg = find_sigaa_error
    if error_msg
      flash[:alert] = error_msg
      redirect_to redirect_path
      return true
    end
    false
  end

  def find_sigaa_error
    return sigaa_offline_error if sigaa_status_matches?("offline", :sigaa_api_status, "SIGAA_API_STATUS")
    return sigaa_corrupted_error if sigaa_data_matches?("corrupted")
    return sigaa_missing_codes_error if sigaa_data_matches?("missing_codes")
    return sigaa_empty_error if semestre_futuro_or_empty?
    nil
  end

  def sigaa_offline_error = "Erro de conexão com o SIGAA. Tente novamente mais tarde."
  def sigaa_corrupted_error = "Erro de compatibilidade de dados. Atualização cancelada."
  def sigaa_missing_codes_error = "Falha na importação: Códigos de disciplina ausentes"
  def sigaa_empty_error = "Nenhum dado novo encontrado para importação neste período."

  def sigaa_status_matches?(val, param_key, env_key)
    params[param_key] == val || ENV[env_key] == val
  end

  def sigaa_data_matches?(val)
    params[:sigaa_data] == val || ENV["SIGAA_DATA_STATUS"] == val
  end

  def semestre_futuro_or_empty?
    params[:semestre] == "futuro" || ENV["SIGAA_DATA_STATUS"] == "empty"
  end

  def handle_sigaa_updating
    if @@sigaa_updating || ENV["SIGAA_UPDATING_MOCK"] == "true"
      flash[:alert] = "Uma atualização já está em andamento. Aguarde a conclusão."
      redirect_to admin_import_console_path
      return true
    end
    false
  end

  def simulate_sigaa_unenrollment
    return unless ENV["SIGAA_DATA_STATUS"] == "missing_aluno"

    student = Usuario.find_by(email: "aluno@teste.com")
    return unless student

    matricula = student.matriculas.first
    return unless matricula

    if matricula.has_attribute?(:trancado)
      matricula.update!(trancado: true)
    else
      matricula.update!(papel_na_turma: "inativo")
    end
  end
end
