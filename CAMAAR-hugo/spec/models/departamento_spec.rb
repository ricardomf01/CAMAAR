require 'rails_helper'

RSpec.describe Departamento, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      departamento = Departamento.new(nome: 'DEPTO CIÊNCIAS DA COMPUTAÇÃO')
      expect(departamento).to be_valid
    end

    it 'is not valid without a nome' do
      departamento = Departamento.new(nome: nil)
      expect(departamento).not_to be_valid
    end
  end
end
