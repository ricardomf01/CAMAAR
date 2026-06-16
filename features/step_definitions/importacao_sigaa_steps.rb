# Contexto
Dado('que estou autenticado no sistema com o perfil de administrador') do
  admin = Usuario.find_or_create_by!(email: "admin@unb.br") do |u|
    u.nome = "Administrador CAMAAR"
    u.matricula = "admin_matricula"
    u.perfil = "administrador"
    u.ativo = true
    u.password = "admin"
  end

  visit login_path
  fill_in "E-mail ou Matrícula", with: "admin@unb.br"
  fill_in "Senha", with: "admin"
  click_button "Entrar"
end

Dado('acesso a área de integração com o SIGAA') do
  visit admin_import_console_path
end

# Cenário Feliz
Quando('eu solicito a importação de dados do semestre atual') do
  ENV["SIGAA_API_STATUS"] = nil
  ENV["SIGAA_DATA_STATUS"] = nil
  click_button "Carregar Dados do CIC"
end

Então('o sistema deve extrair os dados do SIGAA') do
  # Simulado pela leitura dos arquivos locais no Controller
end

Então('criar as novas instâncias de disciplinas e turmas que ainda não existem') do
  expect(Disciplina.count).to be > 0
  expect(Turma.count).to be > 0
end

Então('exibir a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

# Cenários Tristes
Quando('eu solicito a importação de dados do SIGAA') do
  # O clique ocorrerá no próximo passo
end

Quando('o pacote de dados recebido não contém o {string} de algumas disciplinas') do |campo|
  ENV["SIGAA_API_STATUS"] = nil
  ENV["SIGAA_DATA_STATUS"] = "missing_codes"
  click_button "Carregar Dados do CIC"
end

Então('o sistema deve interromper a criação desses registros específicos') do
  expect(Disciplina.count).to eq(0)
  expect(Turma.count).to eq(0)
end

Então('exibir um relatório de erro informando {string}') do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
end

Quando('eu inicio o processo de importação') do
  # O clique ocorrerá no próximo passo
end

Quando('o servidor do SIGAA está temporariamente indisponível') do
  ENV["SIGAA_DATA_STATUS"] = nil
  ENV["SIGAA_API_STATUS"] = "offline"
  click_button "Carregar Dados do CIC"
end

Então('o sistema deve cancelar a operação') do
  expect(Disciplina.count).to eq(0)
end

Quando('eu solicito a importação de dados para um semestre futuro que ainda não foi cadastrado no SIGAA') do
  ENV["SIGAA_API_STATUS"] = nil
  ENV["SIGAA_DATA_STATUS"] = "empty"
  click_button "Carregar Dados do CIC"
end

Então('o sistema não deve alterar a base de dados atual') do
  expect(Disciplina.count).to eq(0)
end

Então('deve exibir o alerta {string}') do |alerta|
  expect(page).to have_content(alerta)
end
