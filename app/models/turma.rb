class Turma < ApplicationRecord
  self.table_name = "turmas"

  belongs_to :disciplina
  belongs_to :departamento
  belongs_to :docente, class_name: "Usuario", foreign_key: "docente_id", optional: true
  has_many :matriculas, dependent: :destroy
  has_many :usuarios, through: :matriculas
  has_many :formularios, dependent: :destroy

  validates :codigo_turma, presence: true, uniqueness: { scope: :semestre }
  validates :semestre, presence: true
  def codigo
    disciplina&.codigo
  end

  def nome
    codigo_turma
  end

  def matriculas_count
    matriculas.count
  end

  def respostas_count
    formularios.joins(:respostas).count
  end

  def calcular_media_desempenho
    respostas = Resposta.joins(:formulario).where(formularios: { turma_id: id })
    itens = RespostaItem.where(resposta: respostas).joins(:questao_template).where(questoes_template: { tipo: "likert" })
    valores = itens.pluck(:valor_numerico).compact
    valores.any? ? (valores.sum.to_f / valores.size).round(1) : 0.0
  end
end
