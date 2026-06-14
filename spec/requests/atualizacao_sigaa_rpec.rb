require 'rails_helper'

RSpec.describe "Atualização da Base via SIGAA", type: :request do
  let(:admin) { create(:usuario, perfil: 'administrador', ativo: true) }
  let!(:turma_existente) { create(:turma) }
  let!(:matricula) { create(:matricula, turma: turma_existente) }

  before do
    post login_path, params: { email: admin.email, senha: 'password123' }
  end

  describe "PATCH /admin/atualizacoes" do
    context "Cenário Feliz: Sincronização de vínculos" do
      it "atualiza o status da matrícula para refletir trancamento ou nova alocação no SIGAA" do
        fail "Comportamento esperado: Mockar o SIGAA informando alteração no vínculo. Fazer a requisição PATCH. Validar expect(matricula.reload.papel_na_turma).to ter mudado e verificar mensagem de sucesso."
      end
    end

    context "Cenários Tristes: Conflitos e Inconsistências" do
      it "inativa o vínculo na turma, mas mantém o registro histórico intacto caso o aluno já tenha respondido um formulário" do
        fail "Comportamento esperado: Criar uma Resposta associada à matrícula no Setup. Mockar o SIGAA desvinculando o aluno. Garantir que Resposta.count não diminui, mas a matrícula fica inativa."
      end

      it "aborta a transação (rollback) se o SIGAA enviar dados estruturais corrompidos" do
        fail "Comportamento esperado: Injetar JSON inválido/corrompido no mock. Verificar se o ActiveRecord dispara um Rollback e os dados anteriores continuam intactos."
      end

      it "bloqueia uma segunda requisição caso o sistema já esteja processando uma atualização concorrente" do
        fail "Comportamento esperado: Simular um lock no banco (ex: flag 'atualizando: true'). Fazer requisição e garantir que o sistema recusa a ação (ex: redireciona com mensagem 'Atualização já em andamento')."
      end
    end
  end
end
