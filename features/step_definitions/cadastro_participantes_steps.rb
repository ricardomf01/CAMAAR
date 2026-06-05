# Contexto comum
Dado('que o processo de importação gerou novos usuários no banco de dados') do
  fail "Comportamento esperado: Criar registros de Usuarios no banco de dados sem a senha definida (ex: senha_digest igual a nulo)."
end

# Cenário Feliz
Dado('que novos participantes foram importados do SIGAA com a flag ativo como falsa') do
  fail "Comportamento esperado: Criar usuários via ActiveRecord definindo explicitamente o atributo 'ativo: false'."
end

Quando('o sistema envia um e-mail com o link de definição de senha para o endereço eletrônico cadastrado') do
  fail "Comportamento esperado: Checar usando o ActionMailer::Base.deliveries se o e-mail correto de reset/criação de senha foi enfileirado."
end

Quando('o usuário clica no link e cadastra uma senha válida') do
  fail "Comportamento esperado: Usar o Capybara para visitar a url extraída do e-mail simulado, preencher a nova senha e confirmar o envio."
end

Então('o sistema deve alterar o status do usuário para ativo') do
  fail "Comportamento esperado: Fazer reload no objeto Usuario através do ActiveRecord e verificar se 'ativo' passou a ser 'true'."
end

Então('liberar o acesso ao sistema CAMAAR') do
  fail "Comportamento esperado: Verificar se o Capybara identifica o redirecionamento para o dashboard inicial (root_path)."
end

# Cenários Tristes
Dado('que um usuário foi importado do SIGAA, mas ainda não definiu sua senha') do
  fail "Comportamento esperado: Criar o Usuario no banco com 'senha_digest' nulo ou em branco."
end

Quando('ele tenta acessar o sistema inserindo seu e-mail e qualquer senha') do
  fail "Comportamento esperado: Visitar a tela de login via Capybara, preencher o e-mail do usuário inativo, colocar uma senha fictícia e submeter."
end

Então('o sistema deve negar o acesso') do
  fail "Comportamento esperado: Garantir com expect(current_path) que o usuário não foi redirecionado e continua na página de login."
end

Quando('o sistema tenta disparar os e-mails de solicitação de senha') do
  fail "Comportamento esperado: Acionar manualmente (ou pela simulação da importação) a trigger que faria o envio em massa de e-mails."
end

Quando('o endereço eletrônico vindo do SIGAA está mal formatado ou não existe') do
  fail "Comportamento esperado: Mockar os dados do SIGAA com um e-mail que não passa pela validação do formato (ex: 'usuario_sem_arroba')."
end

Então('o sistema deve registrar a falha de envio no log') do
  fail "Comportamento esperado: Inspecionar o banco para ver se um status de erro foi registrado ou verificar uma visualização do log para o administrador."
end

Então('o usuário permanecerá com o status inativo até que a correção seja feita manualmente') do
  fail "Comportamento esperado: Checar com o ActiveRecord se a flag 'ativo' do usuário permanece como 'false'."
end

Dado('que um usuário recém-importado recebeu o e-mail de definição de senha') do
  fail "Comportamento esperado: Gerar o token de senha no banco e garantir que ele foi vinculado ao usuário, simulando o disparo do e-mail."
end

Quando('ele acessa o link após o período de validade') do
  fail "Comportamento esperado: Usar uma biblioteca como o Timecop (ou o helper nativo travel_to do Rails) para avançar o tempo e acessar a rota do link."
end

Então('apresentar um botão para {string} sem alterar o status no banco de dados') do |botao|
  fail "Comportamento esperado: Usar o Capybara para verificar se o botão '#{botao}' apareceu e garantir via ActiveRecord que o status continua inativo."
end
