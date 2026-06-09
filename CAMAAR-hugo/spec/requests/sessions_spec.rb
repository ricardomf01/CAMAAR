require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /login" do
    it "logs in the user and redirects" do
      user = Usuario.create!(nome: "Admin", email: "admin@unb.br", perfil: "administrador", password: "123", ativo: true)
      post login_path, params: { email: user.email, password: "123" }
      expect(response).to redirect_to(admin_dashboard_path)
    end

    it "fails to log in with wrong credentials" do
      post login_path, params: { email: "wrong@unb.br", password: "wrong" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash.now[:alert]).to eq("E-mail ou senha inválidos")
    end
  end

  describe "GET /logout" do
    it "logs out the user and redirects to login_path" do
      get logout_path
      expect(response).to redirect_to(login_path)
    end
  end
end
