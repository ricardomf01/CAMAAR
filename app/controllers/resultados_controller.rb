require "csv"

class ResultadosController < ApplicationController
  before_action :require_admin_for_resultados, only: [:index, :show, :relatorios]

  def index
    @formularios = Formulario.all
  end

  def show
    @formulario = Formulario.find(params[:id])
    @respostas = @formulario.respostas

    if @respostas.empty?
      @mensagem_aviso = "Este formulário ainda não recebeu respostas"
    end

    # Calculate average scores and group responses by question
    @perguntas_metricas = []
    @comentarios = []

    @formulario.template.perguntas.each do |pergunta|
      itens = RespostaItem.where(questao_template: pergunta, resposta: @respostas)

      if pergunta.tipo == "likert"
        valores = itens.pluck(:valor_numerico).compact
        media = valores.any? ? (valores.sum.to_f / valores.size).round(1) : 0.0

        # Calculate percentages
        distribuicao = {}
        (1..5).each do |num|
          count = valores.count(num)
          percentage = valores.any? ? (count.to_f / valores.size * 100).round : 0
          distribuicao[num] = percentage
        end

        @perguntas_metricas << {
          pergunta: pergunta,
          media: media,
          distribuicao: distribuicao,
          count: valores.size
        }
      else
        textos = itens.pluck(:valor_texto).reject(&:blank?)
        @comentarios << {
          pergunta: pergunta,
          respostas: textos
        }
      end
    end
  end

  def relatorios
    @formularios = Formulario.all
  end

  def export_csv_resultado
    unless logged_in? && current_user.perfil == 'administrador'
      flash[:alert] = "Acesso negado. Apenas administradores podem gerar este relatório."
      redirect_to root_path and return
    end

    @formulario = Formulario.find(params[:id] || params[:formulario_id])
    template = @formulario.template

    # Otimização de Consultas (Eager Loading das tabelas associadas)
    formularios = template.formularios.includes(respostas: [:usuario, { resposta_itens: :questao_template }], turma: :disciplina)

    if params[:turma_id].present?
      formularios = formularios.where(turma_id: params[:turma_id])
    end

    if formularios.joins(:respostas).empty?
      flash[:alert] = "Não há dados suficientes para gerar o relatório desta avaliação."
      redirect_to admin_relatorios_path and return
    end

    # Delegação da regra de negócio para o Model
    csv_data = Formulario.to_csv(formularios)

    safe_name = template.titulo.downcase.gsub(/[^a-z0-9]/, '_').squeeze('_')
    send_data csv_data, filename: "resultados_#{safe_name}.csv", type: "text/csv; charset=utf-8"
  end

  private

  def require_admin_for_resultados
    unless logged_in? && current_user.perfil == 'administrador'
      flash[:alert] = "Acesso negado: Perfil não autorizado"
      redirect_to root_path
    end
  end
end
