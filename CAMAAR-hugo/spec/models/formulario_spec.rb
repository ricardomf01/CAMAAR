require 'rails_helper'

RSpec.describe Formulario, type: :model do
  describe 'validations' do
    it 'validates presence of publico_alvo' do
      formulario = Formulario.new(publico_alvo: nil)
      expect(formulario).not_to be_valid
      expect(formulario.errors[:publico_alvo]).to include("Obrigatório: Selecione se o formulário é destinado a docentes ou discentes.")
    end

    it 'validates data_limite is after data_inicio' do
      formulario = Formulario.new(data_inicio: Time.now, data_limite: 1.day.ago)
      formulario.valid?
      expect(formulario.errors[:data_limite]).to include("deve ser posterior à data de início")
    end
  end
end
