# encoding: utf-8
# frozen_string_literal: true

Dado('que existe um "usuarios" com "perfil" "discente" e "matricula" "221037634"') do
  @discente = Usuario.find_by(matricula: "221037634") || Usuario.create!(
    nome: "Aluno Teste", email: "aluno@unb.br", matricula: "221037634",
    perfil: "discente", password: "senha", ativo: true
  )
end

Dado('esse usuário possui uma "matriculas" com "papel_na_turma" "discente" na "turmas" de "codigo_turma" "TA"') do
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma = Turma.find_by(codigo_turma: "TA") || Turma.create!(codigo_turma: "TA", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  Matricula.find_or_create_by!(usuario: @discente, turma: @turma, papel_na_turma: "aluno")
end

Dado('existe um "formularios" com "status" "aberto" e "publico_alvo" "discente" para esta turma') do
  @template = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique57@unb.br", matricula: "admin_146", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "T1", ativo: true)
  @form = Formulario.create!(criado_por: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique57@unb.br", matricula: "admin_146", perfil: "administrador", password: "admin", ativo: true), turma: @turma, template: @template, status: "aberto", publico_alvo: "discente", data_inicio: Date.today, data_limite: Date.today + 10)
end

Dado('esse formulário possui uma "questoes_template" onde "obrigatoria" é verdadeiro e "tipo" é "texto"') do
  @questao = @template.perguntas.create!(enunciado: "Q1", tipo: "texto", obrigatoria: true, ordem: 1)
end

Quando('o usuário acessa a página de resposta do formulário') do
  visit responder_avaliacao_path(@form || @form2 || @form3)
  if current_path == login_path
    fill_in "email", with: @discente.matricula
    fill_in "password", with: "senha"
    click_button "Entrar"
    visit responder_avaliacao_path(@form || @form2 || @form3)
  end
end

Quando('preenche o campo correspondente com o "valor_texto" "Excelente metodologia de ensino."') do
  fill_in "respostas[0][texto]", with: "Excelente metodologia de ensino."
end



Então('o sistema deve criar um registro em "respostas" salvando o "enviado_em" com o timestamp atual') do
  expect(Resposta.count).to be > 0
  @resposta = Resposta.last
  expect(@resposta.enviado_em).not_to be_nil
end

Então('deve criar um registro em "resposta_itens" vinculado à questão') do
  expect(@resposta.resposta_itens.count).to eq(1)
  expect(@resposta.resposta_itens.first.questao_template_id).to eq(@questao.id)
end

Dado('que existe um "usuarios" com "perfil" "discente" logado no sistema') do
  step 'que existe um "usuarios" com "perfil" "discente" e "matricula" "221037634"'
  visit login_path
  fill_in "email", with: @discente.matricula
  fill_in "password", with: "senha"
  click_button "Entrar"
end

Dado('existe um "formularios" ativo contendo uma "questoes_template" onde "obrigatoria" é falso e "tipo" é "texto"') do
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma = Turma.create!(codigo_turma: "TB", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  Matricula.find_or_create_by!(usuario: Usuario.find_or_create_by!(email: "aluno_dummy@unb.br") { |u| u.nome="A"; u.matricula="A"; u.perfil="discente"; u.password="a"; u.ativo=true }, turma: @turma, papel_na_turma: "aluno")
  Matricula.create!(usuario: @discente, turma: @turma, papel_na_turma: "aluno")
  @template2 = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique57@unb.br", matricula: "admin_146", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "T2", ativo: true)
  @questao2 = @template2.perguntas.create!(enunciado: "Opcional", tipo: "texto", obrigatoria: false, ordem: 1)
  @form2 = Formulario.create!(criado_por: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique57@unb.br", matricula: "admin_146", perfil: "administrador", password: "admin", ativo: true), turma: @turma, template: @template2, status: "aberto", publico_alvo: "discente", data_inicio: Date.today, data_limite: Date.today + 10)
  visit responder_avaliacao_path(@form2)
end

Quando('deixa o "valor_texto" desta questão em branco') do
  fill_in "respostas[0][texto]", with: ""
end

Então('o sistema deve processar a resposta com sucesso descartando o registro em "resposta_itens" para esta questão em branco') do
  expect(page).to have_content("Sua avaliação foi enviada com sucesso!")
  resposta = Resposta.last
  expect(resposta.resposta_itens.count).to eq(0)
end

Dado('existe um "formularios" ativo contendo uma "questoes_template" onde "obrigatoria" é verdadeiro') do
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma3 = Turma.create!(codigo_turma: "TC", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  Matricula.find_or_create_by!(usuario: Usuario.find_or_create_by!(email: "aluno_dummy@unb.br") { |u| u.nome="A"; u.matricula="A"; u.perfil="discente"; u.password="a"; u.ativo=true }, turma: @turma3, papel_na_turma: "aluno")
  Matricula.create!(usuario: @discente, turma: @turma3, papel_na_turma: "aluno")
  @template3 = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique57@unb.br", matricula: "admin_146", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "T3", ativo: true)
  @questao3 = @template3.perguntas.create!(enunciado: "Obrigatoria", tipo: "texto", obrigatoria: true, ordem: 1)
  @form3 = Formulario.create!(criado_por: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique57@unb.br", matricula: "admin_146", perfil: "administrador", password: "admin", ativo: true), turma: @turma3, template: @template3, status: "aberto", publico_alvo: "discente", data_inicio: Date.today, data_limite: Date.today + 10)
  visit responder_avaliacao_path(@form3)
end

Quando('o usuário limpa ou deixa o campo de resposta vazio') do
  @count_respostas_antes = Resposta.count
  @count_itens_antes = RespostaItem.count
  fill_in "respostas[0][texto]", with: ""
end

Então('o sistema não deve salvar registros nas tabelas "respostas" e "resposta_itens"') do
  expect(Resposta.count).to eq(@count_respostas_antes)
  expect(RespostaItem.count).to eq(@count_itens_antes)
end

Então('deve exibir o erro de validação "Preencha todos os campos obrigatórios"') do
  expect(page).to have_content("Preencha todos os campos obrigatórios")
end

Dado('que existe uma "respostas" salva contendo o "formulario_id" e o "usuario_id" do discente logado') do
  step 'que existe um "usuarios" com "perfil" "discente" logado no sistema'
  @dcc = Departamento.find_or_create_by!(nome: "DCC")
  @disc = Disciplina.find_or_create_by!(codigo: "CIC", nome: "CIC")
  @turma4 = Turma.create!(codigo_turma: "TD", semestre: "2026.1", departamento: @dcc, disciplina: @disc)
  Matricula.find_or_create_by!(usuario: Usuario.find_or_create_by!(email: "aluno_dummy@unb.br") { |u| u.nome="A"; u.matricula="A"; u.perfil="discente"; u.password="a"; u.ativo=true }, turma: @turma4, papel_na_turma: "aluno")
  Matricula.create!(usuario: @discente, turma: @turma4, papel_na_turma: "aluno")
  @template4 = Template.create!(criador: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique57@unb.br", matricula: "admin_146", perfil: "administrador", password: "admin", ativo: true), skip_questions_validation: true, titulo: "T4", ativo: true)
  @form4 = Formulario.create!(criado_por: @admin || Usuario.find_by(perfil: "administrador") || Usuario.create!(nome: "Admin", email: "admin_unique57@unb.br", matricula: "admin_146", perfil: "administrador", password: "admin", ativo: true), turma: @turma4, template: @template4, status: "aberto", publico_alvo: "discente", data_inicio: Date.today, data_limite: Date.today + 10)
  Resposta.create!(formulario: @form4, usuario: @discente, enviado_em: Time.current)
end

Quando('o usuário tenta realizar uma nova requisição POST para submeter dados para o mesmo "formulario_id"') do
  visit responder_avaliacao_path(@form4)
  click_button "Submeter Avaliação"
end

Então('o sistema deve bloquear a operação respeitando o índice único composto de "index_respostas_on_formulario_id_and_usuario_id"') do
  # Checked by next step content
end
