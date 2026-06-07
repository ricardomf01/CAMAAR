require 'rails_helper'

RSpec.describe "Admin::ImportacoesSigaa", type: :request do
  describe "POST /admin/importacoes_sigaa" do
    context "quando o usuário é um Administrador logado" do
      it "importa os dados do semestre atual com sucesso criando novas disciplinas e turmas" do
        fail "Pendente: Implementar a requisição POST para a importação, o mock de sucesso da API do SIGAA e a verificação no banco de dados"
      end

      it "interrompe a criação de registros específicos se campos obrigatórios estiverem ausentes no pacote de dados" do
        fail "Pendente: Implementar validação e interrupção parcial quando o payload do SIGAA vier sem o 'código' das disciplinas"
      end

      it "cancela a operação se houver falha de conexão ou indisponibilidade no servidor do SIGAA" do
        fail "Pendente: Implementar tratamento de exceções (como timeout ou 503) na comunicação com o SIGAA"
      end

      it "não altera a base de dados atual se o conjunto de dados para importação for vazio" do
        fail "Pendente: Implementar a verificação de ausência de novos dados e garantir que nenhum registro seja criado"
      end
    end

    context "quando o usuário é Docente ou Discente" do
      it "bloqueia o acesso e redireciona para a página inicial" do
        fail "Pendente: Implementar bloqueio de rota e política de autorização para usuários sem permissão administrativa"
      end
    end
  end
end
