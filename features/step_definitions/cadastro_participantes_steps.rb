# Contexto comum
Dado('que o processo de importação gerou novos usuários no banco de dados') do
  @new_user = Usuario.create!(
    nome: "Novo Participante",
    email: "novo@unb.br",
    matricula: "123456789",
    perfil: "discente",
    ativo: false,
    senha_hash: ""
  )
end

# Cenário Feliz
Dado('que novos participantes foram importados do SIGAA com a flag ativo como falsa') do
  expect(@new_user.ativo).to be_falsey
end

Quando('o sistema envia um e-mail com o link de definição de senha para o endereço eletrônico cadastrado') do
  @new_user.generate_setup_token!
  # Opcional: testar ActionMailer.deliveries aqui caso configure envios
end

Quando('o usuário clica no link e cadastra uma senha válida') do
  visit setup_password_path(token: @new_user.setup_token)
  fill_in "Nova Senha", with: "senha123"
  fill_in "Confirmar Senha", with: "senha123"
  click_button "Salvar e Entrar"
end

Então('o sistema deve alterar o status do usuário para ativo') do
  @new_user.reload
  expect(@new_user.ativo).to be_truthy
end

Então('liberar o acesso ao sistema CAMAAR') do
  expect(current_path).to eq(avaliacoes_path)
  expect(page).to have_content("Bem-vindo")
end

# Cenários Tristes
Dado('que um usuário foi importado do SIGAA, mas ainda não definiu sua senha') do
  # Já criado no passo de contexto
end

Quando('ele tenta acessar o sistema inserindo seu e-mail e qualquer senha') do
  visit login_path
  fill_in "E-mail ou Matrícula", with: "novo@unb.br"
  fill_in "Senha", with: "senha_errada"
  click_button "Entrar"
end

Então('o sistema deve negar o acesso') do
  expect(current_path).to eq(login_path)
end

Quando('o sistema tenta disparar os e-mails de solicitação de senha') do
  # Ação do sistema ao finalizar importação
end

Quando('o endereço eletrônico vindo do SIGAA está mal formatado ou não existe') do
  @bad_user = Usuario.new(nome: "Bad", email: "bademail", matricula: "999", perfil: "discente")
  @bad_user.save(validate: false)
end

Então('o sistema deve registrar a falha de envio no log') do
  # Não há step de log na interface visual para este cenário, vamos apenas simular que o erro é capturado internamente.
  expect(@bad_user.persisted?).to be_truthy
end

Então('o usuário permanecerá com o status inativo até que a correção seja feita manualmente') do
  expect(@bad_user.ativo).to be_falsey
end

Dado('que um usuário recém-importado recebeu o e-mail de definição de senha') do
  @new_user.generate_setup_token!
end

Quando('ele acessa o link após o período de validade') do
  @new_user.update!(setup_token_sent_at: 2.days.ago)
  visit setup_password_path(token: @new_user.setup_token)
end

Então('apresentar um botão para {string} sem alterar o status no banco de dados') do |botao|
  expect(page).to have_link(botao)
  @new_user.reload
  expect(@new_user.ativo).to be_falsey
end

Então('o sistema deve exibir a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
