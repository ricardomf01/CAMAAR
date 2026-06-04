require 'rails_helper'

RSpec.describe "Admin::Relatorios", type: :request do
  describe "GET /admin/relatorios/csv" do
    context "quando o usuário é um Administrador logado" do
      it "faz o download do arquivo CSV com sucesso" do
        # Forçamos a falha para manter o Estado RED
        fail "Pendente: Implementar rota e controller para download de CSV do administrador"
      end
    end

    context "quando o usuário é Docente ou Discente" do
      it "bloqueia o acesso e redireciona para a página inicial" do
        fail "Pendente: Implementar bloqueio de rota para usuários sem permissão administrativa"
      end
    end
  end
end

