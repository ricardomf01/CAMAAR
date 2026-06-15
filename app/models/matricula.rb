class Matricula < ApplicationRecord
  self.table_name = "matriculas"

  belongs_to :turma
  belongs_to :usuario
end
