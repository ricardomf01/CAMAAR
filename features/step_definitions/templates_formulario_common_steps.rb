Dado('que estou logado como um usuário Administrador') do
  admin = Usuario.find_or_initialize_by(email: "admin@unb.br")
  admin.nome ||= "Admin Teste"
  admin.perfil = "administrador"
  admin.ativo = true
  admin.password = "admin123"
  admin.save!(validate: false)

  visit login_path
  fill_in "E-mail ou Matrícula", with: "admin@unb.br"
  fill_in "Senha", with: "admin123"
  click_button "Entrar"
end

Dado('que estou logado como um usuário {string}') do |perfil|
  u = Usuario.create!(nome: "Participante", email: "part@unb.br", perfil: "discente", password: "123", ativo: true)
  visit login_path
  fill_in "E-mail ou Matrícula", with: "part@unb.br"
  fill_in "Senha", with: "123"
  click_button "Entrar"
end

Quando('preencho o campo {string} com {string}') do |field, value|
  fill_in field, with: value
end

Quando('clico em {string}') do |button|
  click_link_or_button button
end

Então('devo ver a mensagem de sucesso {string}') do |expected_msg|
  expect(page).to have_content(expected_msg)
end

Então('devo ver a mensagem de erro {string}') do |expected_msg|
  expect(page).to have_content(expected_msg)
end

Então('devo ver a mensagem {string}') do |msg|
  expect(page).to have_content(msg)
end

Então('devo ver uma mensagem de alerta {string}') do |msg|
  expect(page).to have_content(msg)
end
