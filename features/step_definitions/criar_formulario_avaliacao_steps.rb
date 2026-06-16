# encoding: utf-8
# frozen_string_literal: true

Dado('que eu estou logado como um "usuarios" cujo "perfil" é "administrador"') do
  @admin = Usuario.find_by(perfil: 'administrador') || Usuario.create!(
    nome: "Administrador", email: "admin@unb.br", matricula: "admin",
    perfil: "administrador", password: "admin", ativo: true
  )
  visit login_path
  fill_in "E-mail ou Matrícula", with: @admin.email
  fill_in "Senha", with: "admin"
  click_button "Entrar"
end

Dado('existe um "templates" ativo com "titulo" "Avaliação Semestral CIC"') do
  @template = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique798@unb.br", matricula: "admin_274", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "Avaliação Semestral CIC", ativo: true, perfil_alvo: "discente")
  @template.perguntas.create!(enunciado: "O que achou?", tipo: "texto", obrigatoria: true, ordem: 1)
end

Dado('existe uma "turmas" cadastrada com "codigo_turma" "TA" e "semestre" "2026.1"') do
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma = Turma.create!(codigo_turma: "TA", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  Matricula.find_or_create_by!(usuario: Usuario.find_or_create_by!(email: "aluno_dummy@unb.br") { |u| u.nome="A"; u.matricula="A"; u.perfil="discente"; u.password="a"; u.ativo=true }, turma: @turma, papel_na_turma: "aluno")
end

Quando('preencho os campos do novo formulário selecionando o template e a turma') do
  visit new_formulario_path
  select @template.titulo, from: "template_id"
  select "#{@turma.codigo} - Turma #{@turma.nome}", from: "turma_id"
end

Quando('defino o "publico_alvo" como "discente"') do
  select "Discentes", from: "publico_alvo"
end

Quando('defino a "data_inicio" para hoje e "data_limite" para daqui a 15 dias') do
  fill_in "data_inicio", with: Date.today.to_s
  fill_in "data_limite", with: (Date.today + 15).to_s
end

Quando('defino o "status" como "aberto"') do
  select "Aberto", from: "status"
end



Então('o sistema deve persistir um novo registro na tabela "formularios" vinculando o "criado_por_id" ao meu ID de usuário') do
  expect(Formulario.count).to be > 0
  form = Formulario.last
  expect(form.criado_por_id).to eq(@admin.id)
end

Dado('que eu estou logado como um "usuarios" com "perfil" "administrador"') do
  step 'que eu estou logado como um "usuarios" cujo "perfil" é "administrador"'
end

Quando('tento criar um "formularios" configurando a "data_limite" para um momento anterior à "data_inicio"') do
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma = Turma.create!(codigo_turma: "TA", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  @template = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique#{rand(1000)}@unb.br", matricula: "admin_#{rand(1000)}", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "Avaliação", ativo: true)

  @count_before = Formulario.count
  visit new_formulario_path
  select @template.titulo, from: "template_id"
  # Use batch creation to avoid any single-select quirks
  find("input.turma-checkbox[value='#{@turma.id}']").set(true)
  select "Discentes", from: "publico_alvo"
  select "Aberto", from: "status"
  fill_in "data_inicio", with: Date.today.to_s
  fill_in "data_limite", with: (Date.today - 1).to_s
end

Então('o model de "formularios" deve falhar nas validações de data') do
  expect(page).to have_content("Erro ao disparar formulários: Data limite deve ser posterior à data de início")
end

Então('o registro não deve ser inserido no banco de dados') do
  expect(Formulario.count).to eq(@count_before)
end

Quando('tento criar um "formularios" passando uma string de 50 caracteres para o campo "publico_alvo"') do
  @form_long = Formulario.new(publico_alvo: "A" * 50)
  @form_long.valid?
end

Então('o sistema deve barrar a requisição antes de violar o limite do banco de dados \("publico_alvo" limit: 20\)') do
  expect(@form_long.errors.full_messages).to include("Publico alvo Público alvo inválido ou muito longo")
end

Então('deve retornar um erro de comprimento de caracteres "Público alvo inválido ou muito longo"') do
  # verified above
end

Dado('que existe um "templates" onde o atributo "ativo" é falso') do
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma = Turma.create!(codigo_turma: "TA", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  @template_inativo = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique#{rand(1000)}@unb.br", matricula: "admin_#{rand(1000)}", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "Template Inativo", ativo: false, perfil_alvo: "discente")
end

Quando('o administrador tenta criar um "formularios" apontando para o "template_id" desse template desativado') do
  # The feature file misses the login step for this scenario, so we do it here.
  @admin = Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique#{rand(1000)}@unb.br", matricula: "admin_#{rand(1000)}", perfil: "administrador", password: "admin", ativo: true)
  visit login_path
  fill_in "email", with: @admin.email
  fill_in "password", with: "admin"
  click_button "Entrar"

  @template_inativo.update!(ativo: true)
  visit new_formulario_path
  @template_inativo.update!(ativo: false)

  select @template_inativo.titulo, from: "template_id"
  find("input.turma-checkbox[value='#{@turma.id}']").set(true)
  select "Discentes", from: "publico_alvo"
  click_button "Disparar Questionários"
end

Então('o sistema deve impedir a criação exibindo o alerta "Não é possível publicar formulários usando templates inativos"') do
  expect(page).to have_content("Não é possível publicar formulários usando templates inativos")
end
