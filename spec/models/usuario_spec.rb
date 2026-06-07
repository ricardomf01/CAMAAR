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

  describe 'setup token' do
    it 'generates a setup token' do
      usuario = Usuario.create(nome: 'Test User', email: 'test@unb.br', perfil: 'discente', ativo: false, password: 'password123')
      usuario.generate_setup_token!
      expect(usuario.setup_token).to be_present
      expect(usuario.setup_token_sent_at).to be_present
      expect(usuario.setup_token_used).to be false
    end
  end
end
