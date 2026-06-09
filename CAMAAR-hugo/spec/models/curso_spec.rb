require 'rails_helper'

RSpec.describe Curso, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      curso = Curso.new(nome: 'Engenharia de Software')
      expect(curso).to be_valid
    end

    it 'is not valid without a nome' do
      curso = Curso.new(nome: nil)
      expect(curso).not_to be_valid
    end
  end
end
