class Turma < ApplicationRecord
  has_many :matriculas, dependent: :destroy
  has_many :formularios, dependent: :destroy
  belongs_to :disciplina
  belongs_to :departamento
  belongs_to :docente, class_name: "Usuario", optional: true
end
