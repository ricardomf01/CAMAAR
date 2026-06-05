# Contexto
Dado('que estou autenticado no sistema com o perfil de administrador') do
  fail "Comportamento esperado: estar logado como um usuário Administrador"
end

Dado('a base de dados do CAMAAR já possui turmas cadastradas') do
  fail "Comportamento esperado: banco de testes com turmas, disciplinas e usuários preexistentes."
end

# Cenário Feliz
Quando('eu solicito a atualização dos dados do SIGAA') do
  fail "Comportamento esperado: Clicar no botão 'Atualizar Base' na página correspondente via Capybara."
end

Quando('um usuário alterou seu vínculo \(trancamento ou nova matrícula) no sistema origem') do
  fail "Comportamento esperado: Mockar a resposta da API do SIGAA para retornar esse usuário com um status de matrícula diferente do atual."
end

Então('o sistema deve atualizar a tabela de matrículas correspondente para refletir o status atual') do
  fail "Comportamento esperado: Fazer uma query na model Matricula e usar expect() para validar se o atributo 'papel_na_turma' ou o status foi alterado no banco."
end

# Cenários Tristes
Dado('que um discente já enviou uma resposta para um formulário de avaliação') do
  fail "Comportamento esperado: Inserir via ActiveRecord um fluxo completo pré-criado: Usuario, Turma, Matricula, Formulario e Resposta com os devidos IDs associados."
end

Quando('eu solicito a atualização da base do SIGAA') do
  fail "Comportamento esperado: Acionar o botão de atualização na view via Capybara."
end

Quando('o SIGAA informa que este aluno não está mais matriculado na turma') do
  fail "Comportamento esperado: Mockar a resposta do SIGAA entregando a lista de alunos da turma sem incluir este aluno específico."
end

Então('o sistema deve manter o registro histórico da resposta intacto por segurança') do
  fail "Comportamento esperado: Buscar a Resposta específica do aluno no banco e confirmar que ela ainda existe e não foi modificada."
end

Então('apenas inativar o vínculo na turma pertinente, informando a ressalva no log de atualização') do
  fail "Comportamento esperado: Validar se a matrícula foi inativada na tabela e buscar a mensagem de alerta/log na interface via Capybara."
end

Quando('o SIGAA envia dados estruturais corrompidos durante a execução da rotina') do
  fail "Comportamento esperado: Mockar a API para retornar um JSON quebrado (ex: strings em vez de inteiros) no meio da transação."
end

Então('o sistema deve abortar a transação para manter a integridade da base') do
  fail "Comportamento esperado: Verificar via ActiveRecord se houve Rollback, confirmando que os dados antes da tentativa continuam intactos."
end

Dado('que o sistema está processando uma atualização de grande volume do SIGAA') do
  fail "Comportamento esperado: Simular o travamento de sistema alterando uma flag (ex: tabela config) ou iniciando um job longo e assíncrono."
end

Quando('outro administrador tenta iniciar o mesmo processo de atualização simultaneamente') do
  fail "Comportamento esperado: Simular os passos de um segundo usuário autenticado acessando a tela e tentando iniciar uma nova atualização."
end

Então('o sistema deve bloquear a segunda requisição') do
  fail "Comportamento esperado: Verificar com Capybara se o botão está desabilitado (disabled) ou se a action do controller recusa o comando."
end
