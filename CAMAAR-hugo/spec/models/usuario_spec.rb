require 'rails_helper'

RSpec.describe Usuario, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      usuario = Usuario.new(nome: 'Test User', email: 'test@unb.br', perfil: 'discente', ativo: true)
      usuario.password = '123456'
      expect(usuario).to be_valid
    end

    it 'is not valid without an email' do
      usuario = Usuario.new(nome: 'Test', email: nil, perfil: 'discente')
      expect(usuario).not_to be_valid
    end
  end
end
