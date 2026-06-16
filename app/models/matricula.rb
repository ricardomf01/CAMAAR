class Matricula < ApplicationRecord
  belongs_to :turma
  belongs_to :usuario
end
