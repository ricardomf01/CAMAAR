# --- CONTEXTO ---

Dado('que existe um administrador logado no CAMAAR') do
  fail "Pendente: Realizar login do usuário com perfil administrador"
end

Dado('o semestre letivo atual está configurado') do
  fail "Pendente: Configurar o semestre letivo atual no banco de dados"
end

Dado('existe a turma {string} com {int} docente e {int} discentes vinculados') do |nome_turma, qtd_docentes, qtd_discentes|
  fail "Pendente: Criar turma #{nome_turma} com #{qtd_docentes} docente e #{qtd_discentes} alunos"
end


# --- GIVENS (PREPARAÇÃO) ---

Dado('que o administrador acessa a página de criação de formulário para a turma {string}') do |nome_turma|
  fail "Pendente: Navegar para a rota de criação de formulário da turma #{nome_turma}"
end

Dado('que o administrador inicia a criação de um novo formulário para uma turma') do
  fail "Pendente: Simular início da criação de formulário genérico"
end

Dado('que a turma {string} foi recém-criada e ainda não possui alunos \(discentes) matriculados') do |nome_turma|
  fail "Pendente: Criar turma #{nome_turma} sem vincular nenhuma matrícula de aluno"
end

Dado('que a turma {string} já possui um formulário ativo direcionado aos {string}') do |nome_turma, publico|
  fail "Pendente: Inserir formulário ativo para #{publico} na turma #{nome_turma}"
end


# --- WHENS (AÇÕES) ---

Quando('ele preenche os dados do formulário com o título {string}') do |titulo|
  fail "Pendente: Preencher campo de título com #{titulo}"
end

Quando('seleciona o público-alvo como {string}') do |publico|
  fail "Pendente: Selecionar o rádio/select de público-alvo para #{publico}"
end

Quando('clica em {string}') do |nome_botao|
  fail "Pendente: Simular o clique no botão #{nome_botao}"
end

Quando('tenta clicar em {string}') do |nome_botao|
  fail "Pendente: Simular o clique no botão #{nome_botao} aguardando bloqueio"
end

Quando('ele preenche todas as perguntas da avaliação') do
  fail "Pendente: Preencher lista de perguntas dinâmicas do formulário"
end

Quando('deixa o campo de seleção {string} em branco') do |nome_campo|
  fail "Pendente: Garantir que o campo #{nome_campo} fique não preenchido/nil"
end

Quando('o administrador tenta criar um formulário selecionando o público-alvo como {string} para esta turma') do |publico|
  fail "Pendente: Submeter formulário com público #{publico} em turma vazia"
end

Quando('o administrador tenta criar uma nova avaliação e seleciona novamente {string} como público-alvo') do |publico|
  fail "Pendente: Tentar sobrepor formulário para #{publico}"
end


# --- THENS (VALIDAÇÕES) ---

Então('o sistema deve registrar o formulário com sucesso') do
  fail "Pendente: Checar se o formulário foi salvo no banco de dados"
end

Então('o formulário deve ficar disponível apenas no painel dos alunos \(discentes) matriculados nesta turma') do
  fail "Pendente: Validar visibilidade exclusiva para alunos da turma"
end

Então('o sistema não deve permitir que o docente da turma responda a este formulário') do
  fail "Pendente: Validar restrição de acesso do docente ao formulário de alunos"
end

Então('o formulário deve ficar disponível exclusivamente no painel do professor responsável pela turma') do
  fail "Pendente: Validar visibilidade exclusiva para o professor"
end

Então('o sistema não deve notificar ou exibir o formulário para os alunos') do
  fail "Pendente: Garantir que a query de painel dos alunos ignore este formulário"
end

Então('a validação do formulário deve falhar') do
  fail "Pendente: Validar que o registro não foi salvo e retornou erros no model"
end

Então('o sistema deve exibir a mensagem de erro {string}') do |mensagem|
  fail "Pendente: Checar no HTML a presença do erro: #{mensagem}"
end

Então('a criação deve ser bloqueada') do
  fail "Pendente: Validar bloqueio da transação no controller"
end

Então('o sistema deve exibir o alerta {string}') do |mensagem|
  fail "Pendente: Checar no HTML a presença do alerta: #{mensagem}"
end

Então('o sistema deve interceptar a ação') do
  fail "Pendente: Validar interceptação de duplicidade de formulário ativo"
end

Então('exibir a mensagem de aviso {string}') do |mensagem|
  fail "Pendente: Checar no HTML a presença do aviso: #{mensagem}"
end
