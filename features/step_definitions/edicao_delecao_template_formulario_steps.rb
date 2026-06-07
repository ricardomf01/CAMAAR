Dado('que existem os seguintes templates criados por mim no sistema:') do |table|
  admin = Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin@unb.br", perfil: "administrador", password: "123")
  table.hashes.each do |row|
    t = Template.new(
      titulo: row['titulo'],
      descricao: row['descricao'],
      criador: admin,
      perfil_alvo: 'discente',
      versao: row['versao']
    )
    t.skip_questions_validation = true
    t.save!(validate: false)
    QuestaoTemplate.create!(template: t, enunciado: "Questão", tipo: "texto", ordem: 1)
  end
end

Dado('que estou na página de listagem de templates') do
  visit templates_path
end

Quando('clico em {string} no template {string}') do |acao, titulo|
  within(:xpath, "//div[contains(@class, 'flex items-center justify-between') and .//p[text()='#{titulo}']]") do
    click_link acao
  end
end

Então('o template deve constar com o título {string} no sistema') do |titulo|
  expect(Template.exists?(titulo: titulo)).to be true
end

Então('o template deve constar com a descrição {string} no sistema') do |desc|
  expect(Template.exists?(descricao: desc)).to be true
end

Dado('o template {string} não possui nenhum formulário associado') do |titulo|
  t = Template.find_by(titulo: titulo)
  t.formularios.destroy_all if t
end

Então('o template {string} não deve mais constar no sistema') do |titulo|
  expect(Template.exists?(titulo: titulo)).to be false
end

Dado('existe um formulário ativo gerado a partir do template {string}') do |titulo|
  t = Template.find_by(titulo: titulo)
  admin = Usuario.find_by(perfil: "administrador")
  dcc = Departamento.find_or_create_by!(nome: "DCC")
  disc = Disciplina.find_or_create_by!(codigo: "CIC01", nome: "M")
  turma = Turma.create!(codigo_turma: "TA_NEW", semestre: "2026.1", disciplina: disc, departamento: dcc)
  
  # Adicionar um aluno à turma para passar na validação do Formulario
  aluno = Usuario.create!(nome: "Aluno", email: "aluno@unb.br", matricula: "123", perfil: "discente", password: "123")
  Matricula.create!(usuario: aluno, turma: turma, papel_na_turma: "aluno")
  
  Formulario.create!(template: t, turma: turma, criado_por: admin, publico_alvo: "discente", status: "aberto", data_inicio: Time.current, data_limite: Time.current + 7.days)
end

Então('o template {string} deve continuar intacto no sistema') do |titulo|
  expect(Template.exists?(titulo: titulo)).to be true
end
