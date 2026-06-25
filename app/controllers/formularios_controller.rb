class FormulariosController < ApplicationController
  before_action :require_admin

  def new
    @templates = Template.all
    @turmas = Turma.all
    @formulario = Formulario.new
  end

  def create
    form_params = extract_formulario_params

    if form_params[:turma_id].present?
      create_single(form_params)
    else
      create_batch(form_params)
    end
  end

  private

  def extract_formulario_params
    {
      publico_alvo: parse_publico_alvo,
      template_id: resolve_param(:template_id),
      status: resolve_param(:status) || "aberto",
      data_inicio: parse_time(resolve_param(:data_inicio)),
      data_limite: parse_time(resolve_param(:data_limite)),
      turma_id: resolve_param(:turma_id),
      turma_ids: params[:turma_ids]
    }
  end

  def parse_publico_alvo
    raw = resolve_param(:publico_alvo).to_s.downcase
    return "discente" if raw.include?("discente")
    return "docente" if raw.include?("docente")
    raw
  end

  def resolve_param(key)
    params[key] || params[:formulario]&.[](key)
  end

  def parse_time(val)
    return Time.parse(val) if val.is_a?(String) && val.present?
    val
  rescue StandardError
    val
  end

  def create_single(form_params)
    @formulario = Formulario.new(
      template: Template.find_by(id: form_params[:template_id]),
      turma_id: form_params[:turma_id],
      criado_por: current_user,
      publico_alvo: form_params[:publico_alvo],
      status: form_params[:status],
      data_inicio: form_params[:data_inicio],
      data_limite: form_params[:data_limite]
    )

    if @formulario.save
      flash[:notice] = "Formulário criado com sucesso!"
      redirect_to admin_dashboard_path
    else
      handle_single_creation_error
    end
  end

  def handle_single_creation_error
    @templates = Template.all
    @turmas = Turma.all
    flash.now[:alert] = extract_validation_message
    render :new, status: :unprocessable_entity
  end

  def extract_validation_message
    formulario_error_message || @formulario.errors.full_messages.first
  end

  def formulario_error_message
    msgs = @formulario.errors.full_messages
    alvo_errs = @formulario.errors[:publico_alvo]
    return template_inativo_msg(msgs) if template_inativo_error?(msgs)
    return alvo_error_msg(alvo_errs) if alvo_errs.any?
    return discentes_msg(msgs) if msgs.any? { |m| m.include?("discentes vinculados") }
    return formulario_ativo_msg(msgs) if msgs.any? { |m| m.include?("Já existe um formulário ativo") }
    return "Datas de início e limite são obrigatórias" if dates_blank?
    nil
  end

  def template_inativo_msg(_msgs) = "Não é possível publicar formulários usando templates inativos"
  def discentes_msg(_msgs) = "Ação inválida: Esta turma ainda não possui discentes vinculados no SIGAA para responderem à avaliação."
  def formulario_ativo_msg(_msgs) = "Atenção: Já existe um formulário ativo para os discentes desta turma. Encerre o atual antes de publicar um novo."

  def alvo_error_msg(errs)
    return "Obrigatório: Selecione se o formulário é destinado a docentes ou discentes." if errs.any? { |e| e.include?("Obrigatório") }
    return "Público alvo inválido ou muito longo" if errs.any? { |e| e.include?("muito longo") }
    nil
  end

  def dates_blank?
    @formulario.errors[:data_inicio].any? || @formulario.errors[:data_limite].any?
  end

  def template_inativo_error?(msgs)
    @formulario.errors[:template_id].any? { |e| e.include?("templates inativos") } ||
      msgs.any? { |m| m.include?("templates inativos") }
  end

  def create_batch(form_params)
    return redirect_no_turmas if form_params[:turma_ids].blank?

    template = Template.find_by(id: form_params[:template_id])
    errors, created_count = run_batch_transaction(template, form_params)
    handle_batch_result(errors, created_count, template)
  end

  def redirect_no_turmas
    flash[:alert] = "Selecione pelo menos uma turma para distribuir os formulários."
    redirect_to new_formulario_path
  end

  def run_batch_transaction(template, form_params)
    errors = []
    created_count = 0
    ActiveRecord::Base.transaction do
      form_params[:turma_ids].each do |t_id|
        form = build_batch_formulario(template, t_id, form_params)
        form.save ? (created_count += 1) : (errors << form.errors.full_messages.first; raise ActiveRecord::Rollback)
      end
    end
    [ errors, created_count ]
  end

  def build_batch_formulario(template, t_id, form_params)
    Formulario.new(
      template: template,
      turma_id: t_id,
      criado_por: current_user,
      publico_alvo: form_params[:publico_alvo] || template&.perfil_alvo || "discente",
      status: form_params[:status],
      data_inicio: form_params[:data_inicio] || Time.current,
      data_limite: form_params[:data_limite] || (Time.current + 7.days)
    )
  end

  def handle_batch_result(errors, created_count, template)
    if errors.any?
      flash[:alert] = "Erro ao disparar formulários: #{errors.join(', ')}"
      redirect_to new_formulario_path
    else
      flash[:notice] = "Formulário '#{template&.titulo}' disparado para #{created_count} turmas com sucesso!"
      redirect_to admin_dashboard_path
    end
  end
end
