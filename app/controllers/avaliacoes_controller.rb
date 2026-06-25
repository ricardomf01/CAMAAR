class AvaliacoesController < ApplicationController
  before_action :require_user
  before_action :set_formulario, only: [ :new, :create ]

  def index
    case current_user.perfil
    when "administrador"
      load_admin_pesquisas
    when "docente"
      load_docente_pesquisas
    else
      load_discente_pesquisas
    end
  end

  def new
    # Already set by before_action
  end

  def create
    return if reject_duplicate_submission
    return if reject_missing_fields

    ActiveRecord::Base.transaction do
      @resposta = Resposta.create!(
        formulario: @formulario,
        usuario: current_user,
        enviado_em: Time.current
      )
      create_resposta_items
    end

    flash[:notice] = "Sua avaliação foi enviada com sucesso! Muito obrigado por contribuir."
    redirect_to avaliacoes_path
  rescue => e
    flash[:alert] = "Erro ao enviar avaliação: #{e.message}"
    redirect_to responder_avaliacao_path(@formulario)
  end

  private

  def reject_duplicate_submission
    return false unless Resposta.exists?(formulario: @formulario, usuario: current_user)

    flash[:alert] = "Você já respondeu a este formulário"
    redirect_to avaliacoes_path
    true
  end

  def reject_missing_fields
    return false unless missing_required_fields?

    flash[:alert] = "Preencha todos os campos obrigatórios"
    redirect_to responder_avaliacao_path(@formulario)
    true
  end

  def load_admin_pesquisas
    @pesquisas_pendentes = Formulario.where(status: "aberto")
    @pesquisas_respondidas = Formulario.none
  end

  def load_docente_pesquisas
    turmas = Turma.where(docente_id: current_user.id).pluck(:id)
    load_pesquisas_for(turmas, [ "docente", "docentes" ])
  end

  def load_discente_pesquisas
    turmas = current_user.matriculas.pluck(:turma_id)
    load_pesquisas_for(turmas, [ "discente", "discentes" ])
  end

  def load_pesquisas_for(turma_ids, publico_alvo)
    now = Time.current
    answered_ids = current_user.respostas.pluck(:formulario_id)

    @pesquisas_pendentes = Formulario.where(
      turma_id: turma_ids,
      status: "aberto",
      publico_alvo: publico_alvo
    ).where("data_inicio <= ? AND data_limite >= ?", now, now)

    @pesquisas_respondidas = Formulario.where(id: answered_ids)
    @pesquisas_pendentes = @pesquisas_pendentes.where.not(id: answered_ids) if answered_ids.any?
  end

  def missing_required_fields?
    @formulario.template.perguntas.each_with_index.any? do |pergunta, idx|
      pergunta.obrigatoria? && question_missing_answer?(pergunta, params.dig(:respostas, idx.to_s))
    end
  end

  def question_missing_answer?(pergunta, resp_param)
    return true if resp_param.nil?

    if pergunta.tipo == "likert"
      resp_param[:nota].blank?
    else
      resp_param[:texto].blank?
    end
  end

  def create_resposta_items
    @formulario.template.perguntas.each_with_index do |pergunta, idx|
      resp_param = params.dig(:respostas, idx.to_s)
      next if resp_param.nil? || question_missing_answer?(pergunta, resp_param)

      build_resposta_item(pergunta, resp_param)
    end
  end

  def build_resposta_item(pergunta, resp_param)
    RespostaItem.create!(
      resposta: @resposta,
      questao_template: pergunta,
      valor_numerico: resp_param[:nota],
      valor_texto: resp_param[:texto],
      valor_opcao: resp_param[:nota].present? ? "Nota #{resp_param[:nota]}" : nil
    )
  end

  private

  def set_formulario
    @formulario = Formulario.find(params[:id])
  end
end
