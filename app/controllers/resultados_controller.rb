require "csv"

class ResultadosController < ApplicationController
  before_action :require_admin_for_resultados, only: [ :show, :relatorios ]

  def index
    @formularios = Formulario.all
  end

  def show
    @formulario = Formulario.find(params[:id])
    @respostas = @formulario.respostas
    @mensagem_aviso = "Este formulário ainda não recebeu respostas" if @respostas.empty?

    @perguntas_metricas = []
    @comentarios = []

    @formulario.template.perguntas.each do |pergunta|
      process_pergunta(pergunta)
    end
  end

  def relatorios
    @formularios = Formulario.all
  end

  def export_csv_resultado
    return if require_admin_export_access

    @formulario = Formulario.find(params[:id] || params[:formulario_id])
    template = @formulario.template
    formularios = filter_formularios(template.formularios)

    return if check_empty_responses(formularios)

    csv_data = generate_csv_data(formularios)
    send_csv_response(csv_data, template)
  end

  private

  def process_pergunta(pergunta)
    itens = RespostaItem.where(questao_template: pergunta, resposta: @respostas)
    if pergunta.tipo == "likert"
      @perguntas_metricas << process_likert_question(pergunta, itens)
    else
      @comentarios << process_text_question(pergunta, itens)
    end
  end

  def process_likert_question(pergunta, itens)
    valores = itens.pluck(:valor_numerico).compact

    {
      pergunta: pergunta,
      media: calcular_media(valores),
      distribuicao: calcular_distribuicao(valores),
      count: valores.size
    }
  end

  def calcular_media(valores)
    valores.any? ? (valores.sum.to_f / valores.size).round(1) : 0.0
  end

  def calcular_distribuicao(valores)
    (1..5).to_h do |num|
      count = valores.count(num)
      percentage = valores.any? ? (count.to_f / valores.size * 100).round : 0
      [num, percentage]
    end
  end

  def process_text_question(pergunta, itens)
    {
      pergunta: pergunta,
      respostas: itens.pluck(:valor_texto).reject(&:blank?)
    }
  end

  def require_admin_export_access
    unless logged_in? && current_user.perfil == "administrador"
      flash[:alert] = "Acesso negado. Apenas administradores podem gerar este relatório."
      redirect_to "/"
      return true
    end
    false
  end

  def check_empty_responses(formularios)
    if formularios.joins(:respostas).count == 0
      flash[:alert] = "Não há dados suficientes para gerar o relatório desta avaliação."
      redirect_to admin_relatorios_path
      return true
    end
    false
  end

  def filter_formularios(formularios)
    params[:turma_id].present? ? formularios.where(turma_id: params[:turma_id]) : formularios
  end

  def send_csv_response(csv_data, template)
    safe_name = template.titulo.downcase.gsub(/[^a-z0-9]/, "_").squeeze("_")
    filename = "resultados_#{safe_name}.csv"
    flash[:notice] = "Relatório gerado com sucesso."
    send_data csv_data, filename: filename, type: "text/csv; charset=utf-8"
  end

  def generate_csv_data(formularios)
    CSV.generate(headers: true, col_sep: ",", encoding: "UTF-8") do |csv|
      csv << [ "Matrícula", "Turma", "Disciplina", "Respostas" ]

      formularios.each do |form|
        form.respostas.each do |resp|
          next unless valid_turma_response?(resp, params[:turma_id])
          append_resposta_itens_to_csv(csv, form, resp)
        end
      end
    end
  end

  def valid_turma_response?(resp, turma_id_param)
    return true if turma_id_param.blank?
    resp.usuario.matriculas.pluck(:turma_id).include?(turma_id_param.to_i)
  end

  def append_resposta_itens_to_csv(csv, form, resp)
    aluno_turma = extract_aluno_turma(form, resp)
    matricula = resp.usuario.matricula || "Anônimo"
    
    resp.resposta_itens.each do |item|
      csv << [ matricula, aluno_turma.codigo_turma, aluno_turma.disciplina.nome, extract_item_value(item) ]
    end
  end

  def extract_aluno_turma(form, resp)
    resp.usuario.matriculas.find_by(turma_id: form.turma_id)&.turma || form.turma
  end

  def extract_item_value(item)
    item.questao_template.tipo == "likert" ? item.valor_numerico.to_s : item.valor_texto
  end

  def require_admin_for_resultados
    unless logged_in? && current_user.perfil == "administrador"
      flash[:alert] = "Acesso negado: Perfil não autorizado"
      redirect_to "/"
    end
  end
end
