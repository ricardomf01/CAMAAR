require 'rails_helper'

RSpec.describe "Admins", type: :request do
  let(:admin_user) do
    Usuario.create!(
      nome: "Admin",
      email: "admin@unb.br",
      perfil: "administrador",
      password: "123",
      ativo: true
    )
  end

  before do
    post login_path, params: { email: admin_user.email, password: "123" }
  end

  describe "GET /admin/dashboard" do
    it "returns http success" do
      get admin_dashboard_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/turmas" do
    it "returns http success" do
      get admin_turmas_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/desempenho_semestral" do
    it "returns http success" do
      get admin_desempenho_semestral_path
      expect(response).to have_http_status(:success)
    end
  end

  # --- INÍCIO DOS TESTES DA ISSUE #106 (ESTADO RED) ---
  describe "Sistema de gerenciamento por departamento (Issue #106)" do
    context "Visualização de turmas" do
      it "lista apenas as turmas pertencentes ao departamento do administrador" do
        fail "Pendente: Implementar o filtro de turmas pelo departamento do Admin na listagem"
      end

      it "exibe uma lista vazia e uma mensagem de aviso caso o departamento não tenha turmas" do
        fail "Pendente: Tratar fluxo alternativo quando não há turmas no departamento"
      end
    end

    context "Segurança e Isolamento" do
      it "bloqueia o acesso direto à URL de uma turma de outro departamento" do
        fail "Pendente: Implementar o bloqueio de rota (before_action) para departamentos cruzados"
      end

      it "redireciona para o painel principal exibindo erro de permissão" do
        fail "Pendente: Implementar o redirecionamento seguro com mensagem de erro"
      end
    end
  end
end
