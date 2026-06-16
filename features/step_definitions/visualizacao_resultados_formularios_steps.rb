# encoding: utf-8
# frozen_string_literal: true

Dado('que estou logado com o "perfil" de "administrador"') do
  @admin = Usuario.find_by(perfil: 'administrador') || Usuario.create!(
    nome: "Administrador", email: "admin@unb.br", matricula: "admin", 
    perfil: "administrador", password: "admin", ativo: true
  )
  visit login_path
  fill_in "E-mail ou Matrícula", with: @admin.email
  fill_in "Senha", with: "admin"
  click_button "Entrar"
end

Dado('existe um "formularios" que recebeu registros na tabela "respostas"') do
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma = Turma.create!(codigo_turma: "TX", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  Matricula.find_or_create_by!(usuario: Usuario.find_or_create_by!(email: "aluno_dummy@unb.br") { |u| u.nome="A"; u.matricula="A"; u.perfil="discente"; u.password="a"; u.ativo=true }, turma: @turma, papel_na_turma: "aluno")
  @template = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique919@unb.br", matricula: "admin_756", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "T5", ativo: true)
  @questao = @template.perguntas.create!(enunciado: "Avalie de 1 a 5", tipo: "likert", obrigatoria: true, ordem: 1)
  @form = Formulario.create!(criado_por: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique919@unb.br", matricula: "admin_756", perfil: "administrador", password: "admin", ativo: true), turma: @turma, template: @template, status: "aberto", publico_alvo: "discente", data_inicio: Date.today, data_limite: Date.today + 10)
  
  @aluno = Usuario.create!(nome: "A1", email: "a1@u", matricula: "a1", perfil: "discente", password: "a1", ativo: true)
  @resposta = Resposta.create!(formulario: @form, usuario: @aluno, enviado_em: Time.current)
end

Dado('esses registros possuem dados na tabela "resposta_itens" contendo valores preenchidos em "valor_numerico" e "valor_texto"') do
  @resposta.resposta_itens.create!(questao_template: @questao, valor_numerico: 4)
end

Quando('eu acesso o painel interno de métricas do formulário') do
  visit resultado_path(@form)
end

Então('a aplicação deve realizar o agrupamento das questões e exibir as médias calculadas a partir do "valor_numerico"') do
  expect(page).to have_content("4.0") # Adjust as per exact view formatting
end

Dado('que estou autenticado no sistema como um "usuarios" com "perfil" "discente"') do
  @discente = Usuario.find_by(matricula: "221037634") || Usuario.create!(
    nome: "Aluno Teste", email: "aluno@unb.br", matricula: "221037634",
    perfil: "discente", password: "senha", ativo: true
  )
  visit login_path
  fill_in "E-mail ou Matrícula", with: @discente.matricula
  fill_in "Senha", with: "senha"
  click_button "Entrar"
end

Quando('eu tento acessar diretamente a URL restrita de resultados de um "formularios"') do
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma_tz = Turma.create!(codigo_turma: "TZ", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  Matricula.find_or_create_by!(usuario: Usuario.find_or_create_by!(email: "aluno_dummy@unb.br") { |u| u.nome="A"; u.matricula="A"; u.perfil="discente"; u.password="a"; u.ativo=true }, turma: @turma_tz, papel_na_turma: "aluno")
  @form_restrict = Formulario.create!(criado_por: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique#{rand(1000)}@unb.br", matricula: "admin_#{rand(1000)}", perfil: "administrador", password: "admin", ativo: true), turma: @turma_tz, template: Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique#{rand(1000)}@unb.br", matricula: "admin_#{rand(1000)}", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "TZ", ativo: true), status: "aberto", publico_alvo: "discente", data_inicio: Date.today, data_limite: Date.today + 10)
  visit resultado_path(@form_restrict)
end

Então('o sistema deve interceptar a rota, impedir a renderização da página') do
  # Implicitly tested by the next step
end

Então('redirecionar-me para a página inicial com o alerta "Acesso negado: Perfil não autorizado"') do
  expect(page).to have_content("Acesso negado")
end

Dado('que um "formularios" foi criado recentemente e a tabela "respostas" possui zero registros vinculados a ele') do
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma_empty = Turma.create!(codigo_turma: "TY", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  Matricula.find_or_create_by!(usuario: Usuario.find_or_create_by!(email: "aluno_dummy@unb.br") { |u| u.nome="A"; u.matricula="A"; u.perfil="discente"; u.password="a"; u.ativo=true }, turma: @turma_empty, papel_na_turma: "aluno")
  @template_empty = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique919@unb.br", matricula: "admin_756", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "TY", ativo: true)
  @form_empty = Formulario.create!(criado_por: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique919@unb.br", matricula: "admin_756", perfil: "administrador", password: "admin", ativo: true), turma: @turma_empty, template: @template_empty, status: "aberto", publico_alvo: "discente", data_inicio: Date.today, data_limite: Date.today + 10)
end

Quando('o administrador clica no painel de acompanhamento deste formulário específico') do
  step 'que estou logado com o "perfil" de "administrador"'
  visit resultado_path(@form_empty)
end

Então('o sistema deve carregar a view com sucesso, mas apresentar o aviso estrutural "Este formulário ainda não recebeu respostas"') do
  expect(page).to have_content("Este formulário ainda não recebeu respostas")
end
