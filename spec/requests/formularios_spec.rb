require 'rails_helper'

RSpec.describe "Formularios e Avaliações", type: :request do
  describe "Visibilidade por Público-Alvo (Issue #113)" do
    context "quando o formulário é para Discentes" do
      it "exibe o formulário no painel do aluno e oculta no painel do professor" do
        fail "Pendente: Implementar filtro de visibilidade no controller de avaliações para discentes"
      end
    end

    context "quando o formulário é para Docentes" do
      it "exibe o formulário no painel do professor e oculta no painel dos alunos" do
        fail "Pendente: Implementar filtro de visibilidade no controller de avaliações para docentes"
      end
    end
  end
end
