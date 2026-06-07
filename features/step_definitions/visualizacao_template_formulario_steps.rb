Dado('que existem os seguintes templates cadastrados no sistema:') do |table|
  admin = Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin@unb.br", perfil: "administrador", password: "123")
  table.hashes.each do |row|
    t = Template.new(
      titulo: row['titulo'],
      descricao: row['descricao'],
      criador: admin,
      perfil_alvo: 'discente'
    )
    t.skip_questions_validation = true
    t.save!(validate: false)
    QuestaoTemplate.create!(template: t, enunciado: "Q1", tipo: "texto", ordem: 1)
  end
end

Quando('acesso a página de gerenciamento de templates') do
  visit templates_path
end

Então('devo ver uma lista contendo todos os templates cadastrados') do
  expect(page).to have_content("Templates Ativos")
end

Então('devo visualizar o template {string}') do |titulo|
  expect(page).to have_content(titulo)
end

Dado('que não existem templates cadastrados no sistema') do
  Template.destroy_all
end

Quando('tento acessar a página de gerenciamento de templates através da URL {string}') do |url|
  visit url
end

Então('devo ser redirecionado para a página inicial') do
  expect(current_path).to eq(avaliacoes_path).or eq(root_path)
end
