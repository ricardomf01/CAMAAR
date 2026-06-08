require 'rails_helper'

RSpec.describe "Cadastro e Ativação de Participantes", type: :request do
  # Usuário criado pela rotina de importação, aguardando definição de senha
  let(:usuario_pendente) { create(:usuario, ativo: false, senha_digest: nil) }

  describe "Acesso e Autenticação" do
    context "Cenário Feliz: Efetivação do cadastro" do
      it "altera o status para ativo e libera o login após o usuário cadastrar uma senha válida via link" do
        fail "Comportamento esperado: Fazer requisição PATCH para a rota de definição de senha (ex: /usuarios/senha) enviando um token válido. Verificar expect(usuario_pendente.reload.ativo).to be true e redirecionamento para root_path."
      end
    end

    context "Cenários Tristes: Tentativas inválidas" do
      it "nega o acesso e exibe mensagem de cadastro pendente caso o usuário inativo tente logar pela tela padrão" do
        fail "Comportamento esperado: Fazer POST na rota de login com o e-mail do usuário inativo. Verificar expect(response).to redirect_to(login_path) com flash alert 'Cadastro pendente: Verifique seu e-mail'."
      end

      it "registra falha no log e mantém o usuário inativo se o e-mail vindo do SIGAA for mal formatado" do
        fail "Comportamento esperado: Simular o disparo de e-mails de ativação para um usuário com e-mail inválido. Validar que o ActionMailer não enfileirou o e-mail e a flag ativo continua false."
      end

      it "exibe mensagem 'Link expirado' e não altera o status se o token de definição de senha estiver fora da validade" do
        fail "Comportamento esperado: Usar o helper 'travel_to' do Rails para avançar no tempo (ex: 3 dias). Tentar usar o token expirado. Validar que a resposta exibe erro e a senha não é atualizada."
      end
    end
  end
end