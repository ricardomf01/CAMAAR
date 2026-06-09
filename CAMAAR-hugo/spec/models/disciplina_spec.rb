require 'rails_helper'

RSpec.describe Disciplina, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      disciplina = Disciplina.new(codigo: 'CIC0001', nome: 'Introdução')
      expect(disciplina).to be_valid
    end

    it 'is not valid without a codigo' do
      disciplina = Disciplina.new(codigo: nil, nome: 'Introdução')
      expect(disciplina).not_to be_valid
    end

    it 'is not valid without a nome' do
      disciplina = Disciplina.new(codigo: 'CIC0001', nome: nil)
      expect(disciplina).not_to be_valid
    end
  end
end
