# --- CONTEXTO ---

Dado('que existe um usuário com o perfil {string} autenticado no sistema CAMAAR') do |perfil|
  fail "Pendente: Implementar autenticação do usuário com perfil #{perfil}"
end

Dado('que os dados de turmas e disciplinas do SIGAA do semestre {string} foram sincronizados') do |semestre|
  fail "Pendente: Implementar sincronização dos dados do semestre #{semestre}"
end

Dado('existe um formulário de avaliação chamado {string}') do |nome_formulario|
  fail "Pendente: Criar no banco de dados o formulário #{nome_formulario}"
end


# --- DADOS DE PREPARAÇÃO DOS CENÁRIOS (GIVENS) ---

Dado('que o formulário {string} possui respostas cadastradas pelos alunos') do |nome_formulario|
  fail "Pendente: Criar respostas simuladas para o formulário #{nome_formulario}"
end

Dado('o administrador acessa a página de {string}') do |nome_pagina|
  fail "Pendente: Implementar navegação para a página #{nome_pagina}"
end

Dado('que o formulário {string} possui respostas para as turmas {string} e {string} de {string}') do |nome_formulario, turma_1, turma_2, disciplina|
  fail "Pendente: Criar respostas específicas para as turmas #{turma_1} e #{turma_2} da disciplina #{disciplina}"
end

Dado('seleciona o formulário {string}') do |nome_formulario|
  fail "Pendente: Implementar seleção silenciosa do formulário #{nome_formulario}"
end

Dado('que foi criado um novo formulário chamado {string}') do |nome_formulario|
  fail "Pendente: Criar um formulário vazio chamado #{nome_formulario}"
end

Dado('o formulário {string} ainda não possui nenhuma resposta') do |nome_formulario|
  fail "Pendente: Validar que o formulário #{nome_formulario} está com 0 respostas"
end


# --- AÇÕES DO USUÁRIO (WHENS) ---

Quando('ele seleciona o formulário {string} na listagem') do |nome_formulario|
  fail "Pendente: Simular o clique no formulário #{nome_formulario} na interface"
end

Quando('clica no botão {string}') do |nome_botao|
  fail "Pendente: Simular o clique no botão #{nome_botao}"
end

Quando('ele filtra os resultados escolhendo apenas a turma {string}') do |nome_turma|
  fail "Pendente: Simular a aplicação do filtro na turma #{nome_turma}"
end

Quando('ele tenta acessar a URL direta de geração de relatórios administrativos em {string}') do |url_direta|
  fail "Pendente: Forçar requisição HTTP GET para a rota #{url_direta}"
end


# --- VALIDAÇÕES DE RESULTADO (THENS) ---

Então('o sistema deve iniciar o download de um arquivo chamado {string}') do |nome_arquivo|
  fail "Pendente: Validar se os headers da resposta disparam o download de #{nome_arquivo}"
end

Então('o arquivo CSV baixado deve conter as colunas {string}, {string}, {string} e {string}') do |coluna1, coluna2, coluna3, coluna4|
  fail "Pendente: Fazer o parse do CSV e validar as colunas #{coluna1}, #{coluna2}, #{coluna3}, #{coluna4}"
end

Então('o sistema deve exibir a mensagem de sucesso {string}') do |mensagem|
  fail "Pendente: Checar no HTML a presença da mensagem de sucesso: #{mensagem}"
end

Então('o arquivo baixado deve conter apenas as respostas dos alunos matriculados na turma {string} de {string}') do |turma, disciplina|
  fail "Pendente: Validar que o CSV exportado contém apenas os alunos da #{turma} de #{disciplina}"
end

Então('o sistema não deve iniciar nenhum download de arquivo') do
  fail "Pendente: Garantir que a resposta HTTP não seja um anexo de download"
end

Então('deve exibir a mensagem de aviso {string}') do |mensagem|
  fail "Pendente: Checar no HTML a presença do aviso: #{mensagem}"
end

Então('o sistema deve redirecioná-lo para a página inicial') do
  fail "Pendente: Validar o redirecionamento (status 302) para a raiz do site"
end

Então('deve exibir a mensagem de erro {string}') do |mensagem|
  fail "Pendente: Checar no HTML a presença do erro: #{mensagem}"
end
