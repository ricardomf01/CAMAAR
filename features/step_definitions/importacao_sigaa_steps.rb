# Contexto
Dado('que estou autenticado no sistema com o perfil de administrador') do
  fail "Comportamento esperado: Criar um usuário administrador no banco e realizar o login através da interface com Capybara."
end

Dado('acesso a área de integração com o SIGAA') do
  fail "Comportamento esperado: Utilizar o Capybara para navegar até a rota da view de integração (ex: visit integracao_sigaa_path)."
end

# Cenário Feliz
Quando('eu solicito a importação de dados do semestre atual') do
  fail "Comportamento esperado: Usar Capybara para clicar no botão ou submeter o formulário que inicia a importação."
end

Então('o sistema deve extrair os dados do SIGAA') do
  fail "Comportamento esperado: Interceptar/mockar a requisição HTTP (ex: WebMock) para a API do SIGAA garantindo que ela retorne um payload de sucesso."
end

Então('criar as novas instâncias de disciplinas e turmas que ainda não existem') do
  fail "Comportamento esperado: Consultar o banco de dados via ActiveRecord (ex: expect(Turma.count).to eq(...)) para verificar se os dados foram inseridos."
end

Então('exibir a mensagem {string}') do |mensagem|
  fail "Comportamento esperado: Usar Capybara para verificar se a flash message '#{mensagem}' está presente na tela."
end

# Cenários Tristes
Quando('eu solicito a importação de dados do SIGAA') do
  fail "Comportamento esperado: Acionar o evento de importação na interface via Capybara."
end

Quando('o pacote de dados recebido não contém o {string} de algumas disciplinas') do |campo|
  fail "Comportamento esperado: Mockar a resposta da API do SIGAA entregando um JSON propositalmente sem a chave '#{campo}'."
end

Então('o sistema deve interromper a criação desses registros específicos') do
  fail "Comportamento esperado: Verificar via ActiveRecord que as disciplinas com dados ausentes não foram salvas na tabela correspondente."
end

Então('exibir um relatório de erro informando {string}') do |mensagem_erro|
  fail "Comportamento esperado: Procurar o alerta '#{mensagem_erro}' na página utilizando Capybara."
end

Quando('eu inicio o processo de importação') do
  fail "Comportamento esperado: Acionar a importação na view utilizando o Capybara."
end

Quando('o servidor do SIGAA está temporariamente indisponível') do
  fail "Comportamento esperado: Mockar a requisição para a API do SIGAA forçando um status HTTP 503 ou um timeout."
end

Então('o sistema deve cancelar a operação') do
  fail "Comportamento esperado: Fazer contagens no banco de dados para garantir que absolutamente nenhum registro foi modificado ou adicionado."
end

Quando('eu solicito a importação de dados para um semestre futuro que ainda não foi cadastrado no SIGAA') do
  fail "Comportamento esperado: Interagir na interface preenchendo o formulário com um semestre futuro e mockar a resposta vazia da API."
end

Então('o sistema não deve alterar a base de dados atual') do
  fail "Comportamento esperado: Checar se o estado (count) das tabelas turmas e disciplinas permaneceu idêntico ao estado inicial."
end

Então('deve exibir o alerta {string}') do |alerta|
  fail "Comportamento esperado: Buscar o aviso '#{alerta}' renderizado na interface usando Capybara."
end
