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
end
