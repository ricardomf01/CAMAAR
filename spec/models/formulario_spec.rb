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


  # --- INÍCIO DOS TESTES DA ISSUE #113 (ESTADO RED) ---
  describe "Regras de público-alvo na criação (Issue #113)" do
    it "é inválido se o público-alvo (docentes ou discentes) não for preenchido" do
      fail "Pendente: Implementar validação de presença para o campo publico_alvo"
    end

    it "impede a criação para discentes se a turma não possuir alunos matriculados" do
      fail "Pendente: Implementar validação que bloqueia formulário em turma sem discentes"
    end

    it "impede a criação de um novo formulário se já houver um ativo para o mesmo público na turma" do
      fail "Pendente: Implementar validação de unicidade de formulário ativo por público-alvo"
    end
  end
end
