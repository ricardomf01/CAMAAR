require 'rails_helper'

RSpec.describe Turma, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      departamento = Departamento.create!(nome: 'DEPTO')
      disciplina = Disciplina.create!(codigo: '123', nome: 'Disp')
      turma = Turma.new(codigo_turma: 'A', semestre: '2023.1', departamento: departamento, disciplina: disciplina)
      expect(turma).to be_valid
    end

    it 'is not valid without codigo_turma' do
      turma = Turma.new(codigo_turma: nil)
      expect(turma).not_to be_valid
    end
  end
end
