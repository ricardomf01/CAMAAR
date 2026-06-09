# --- CONTEXTO ---

Dado('que os dados do SIGAA para o semestre atual {string} foram sincronizados') do |semestre|
  fail "Pendente: Implementar sincronização do SIGAA para o semestre #{semestre}"
end

Dado('existem turmas cadastradas para o departamento {string}') do |nome_departamento|
  fail "Pendente: Cadastrar turmas para o departamento #{nome_departamento}"
end

Dado('existe um usuário {string} autenticado com perfil de {string}') do |nome_usuario, perfil|
  fail "Pendente: Autenticar usuário #{nome_usuario} com perfil #{perfil}"
end

Dado('o usuário {string} está vinculado institucionalmente ao departamento {string}') do |nome_usuario, nome_departamento|
  fail "Pendente: Vincular #{nome_usuario} ao departamento #{nome_departamento}"
end


# --- PASSO COMPARTILHADO (GIVENS / WHENS) ---

Dado('que o {string} acessa o painel de gerenciamento de turmas do semestre atual') do |nome_usuario|
  fail "Pendente: Navegar para o painel de turmas com o usuário #{nome_usuario}"
end

Quando('la listagem de turmas for carregada na tela') do
  fail "Pendente: Simular o carregamento da listagem de turmas na interface"
end

Dado('que o {string} acessa a página de {string}') do |nome_usuario, nome_pagina|
  fail "Pendente: Navegar para a página #{nome_pagina} com o usuário #{nome_usuario}"
end

Dado('que a turma de {string} pertence ao departamento {string} e possui o ID de sistema {string}') do |nome_disciplina, nome_departamento, id_sistema|
  fail "Pendente: Configurar turma #{nome_disciplina} do departamento #{nome_departamento} com ID #{id_sistema}"
end


# --- AÇÕES (WHENS) ---

Quando('ele solicita a geração do relatório consolidado de turmas do semestre {string}') do |semestre|
  fail "Pendente: Solicitar geração de relatório consolidado para o semestre #{semestre}"
end

Quando('o {string} tenta forçar o acesso digitando diretamente a URL {string}') do |nome_usuario, url_direta|
  fail "Pendente: Forçar requisição HTTP para a rota #{url_direta} com o usuário #{nome_usuario}"
end


# --- VALIDAÇÕES DE RESULTADO (THENS) ---

Então('ele deve visualizar as disciplinas referentes ao departamento {string}, como {string}') do |nome_departamento, nome_disciplina|
  fail "Pendente: Validar presença da disciplina #{nome_disciplina} do departamento #{nome_departamento}"
end

Então('a lista não deve exibir nenhuma disciplina referente ao departamento {string}, como {string}') do |nome_departamento, nome_disciplina|
  fail "Pendente: Garantir a ausência da disciplina #{nome_disciplina} do departamento #{nome_departamento}"
end

Então('o sistema deve compilar os dados') do
  fail "Pendente: Validar processamento de compilação de dados do relatório"
end

Então('o relatório gerado deve conter exclusivamente as métricas de avaliação das turmas vinculadas ao {string}') do |nome_departamento|
  fail "Pendente: Validar se métricas pertencem apenas ao departamento #{nome_departamento}"
end

E('os dados consolidados não devem sofrer interferência de notas ou respostas de turmas de outros departamentos') do
  fail "Pendente: Validar isolamento estrito de dados entre departamentos"
end

Então('o sistema deve interceptar a requisição e bloquear o acesso') do
  fail "Pendente: Validar código HTTP de rejeição ou interceptação de segurança"
end

Então('o sistema deve redirecioná-lo para o painel principal do seu departamento') do
  fail "Pendente: Validar redirecionamento seguro pós-bloqueio"
end

Então('exibir a mensagem de erro {string}') do |mensagem|
  fail "Pendente: Checar no HTML a presença do erro: #{mensagem}"
end

Dado('mas a sincronização com o SIGAA não retornou nenhuma turma activa para o departamento {string} no semestre {string}') do |nome_departamento, semestre|
  fail "Pendente: Simular retorno de sincronização vazio para #{nome_departamento} no semestre #{semestre}"
end

Então('a listagem de turmas deve aparecer vazia') do
  fail "Pendente: Validar que nenhum elemento de turma foi renderizado na tabela"
end

Então('o sistema deve exibir a mensagem de aviso {string}') do |mensagem|
  fail "Pendente: Checar no HTML a presença do aviso: #{mensagem}"
end

Então('o botão {string} deve estar desabilitado') do |nome_botao|
  fail "Pendente: Verificar se o elemento HTML do botão #{nome_botao} possui o atributo disabled"
end
