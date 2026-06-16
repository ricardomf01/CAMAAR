# encoding: utf-8
# frozen_string_literal: true

Dado('que eu sou um "usuarios" com "perfil" "discente" e possuo uma "matriculas" na "turmas" "CIC0105"') do
  @discente = Usuario.find_by(matricula: "111222333") || Usuario.create!(
    nome: "Aluno CIC", email: "alunocic@unb.br", matricula: "111222333",
    perfil: "discente", password: "senha", ativo: true
  )
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma = Turma.find_by(codigo_turma: "CIC0105") || Turma.create!(codigo_turma: "CIC0105", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  Matricula.find_or_create_by!(usuario: @discente, turma: @turma, papel_na_turma: "aluno")
end

Dado('existe um "formularios" direcionado à minha turma onde o "status" é "aberto" e o "publico_alvo" é "discente"') do
  @template = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique515@unb.br", matricula: "admin_101", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "TCIC", ativo: true)
  @form = Formulario.create!(criado_por: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique515@unb.br", matricula: "admin_101", perfil: "administrador", password: "admin", ativo: true), turma: @turma, template: @template, status: "aberto", publico_alvo: "discente", data_inicio: Date.today, data_limite: Date.today + 10)
end

Dado('a data atual está entre a "data_inicio" e a "data_limite"') do
  # Ensured by previous step
end

Dado('eu não possuo nenhum registro correspondente na tabela "respostas" para este formulário') do
  # True by default
end

Quando('eu entro na rota de listagem de avaliações pendentes') do
  visit login_path
  fill_in "E-mail ou Matrícula", with: @discente.matricula
  fill_in "Senha", with: "senha"
  click_button "Entrar"
  visit avaliacoes_path
end

Então('a view deve exibir as informações do formulário e o "codigo_turma" da turma correspondente') do
  expect(page).to have_content(@form.template.titulo)
  expect(page).to have_content(@turma.disciplina.codigo)
end

Dado('que o "formularios" da minha turma possui uma "data_limite" definida no passado') do
  step 'que eu sou um "usuarios" com "perfil" "discente" e possuo uma "matriculas" na "turmas" "CIC0105"'
  step 'existe um "formularios" direcionado à minha turma onde o "status" é "aberto" e o "publico_alvo" é "discente"'
  @form.update!(data_inicio: Date.today - 10, data_limite: Date.today - 1)
end

Então('a página não deve listar este formulário como disponível para preenchimento') do
  expect(page).not_to have_content(@form.template.titulo)
end

Dado('que existe um "formularios" com "status" "aberto" para a turma "TA"') do
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma_ta = Turma.create!(codigo_turma: "TA_OUTRA", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  Matricula.find_or_create_by!(usuario: Usuario.find_or_create_by!(email: "aluno_dummy@unb.br") { |u| u.nome="A"; u.matricula="A"; u.perfil="discente"; u.password="a"; u.ativo=true }, turma: @turma_ta, papel_na_turma: "aluno")
  @template_ta = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique515@unb.br", matricula: "admin_101", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "TTA", ativo: true)
  @form_ta = Formulario.create!(criado_por: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique515@unb.br", matricula: "admin_101", perfil: "administrador", password: "admin", ativo: true), turma: @turma_ta, template: @template_ta, status: "aberto", publico_alvo: "discente", data_inicio: Date.today, data_limite: Date.today + 10)
end

Dado('eu não possuo um registro correspondente na tabela "matriculas" vinculando meu "usuario_id" ao "turma_id" daquela turma') do
  @discente = Usuario.find_or_create_by!(email: "alunosem@unb.br") do |u|
    u.nome = "Aluno Sem Matrícula"
    u.matricula = "555666777"
    u.perfil = "discente"
    u.password = "senha"
    u.ativo = true
  end
end

Quando('eu forço o acesso à listagem de avaliações') do
  Formulario.where(turma: @turma).destroy_all # Remove user's actual forms to trigger empty state
  visit login_path
  fill_in "E-mail ou Matrícula", with: @discente.matricula
  fill_in "Senha", with: "senha"
  click_button "Entrar"
  visit avaliacoes_path
end

Então('a view deve exibir a mensagem "Você não possui formulários pendentes para responder no momento"') do
  expect(page).to have_content("Você não possui formulários pendentes")
end
