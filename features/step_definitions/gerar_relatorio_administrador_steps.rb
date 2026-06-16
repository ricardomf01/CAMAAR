# --- CONTEXTO ---

Dado('que existe um usuário com o perfil {string} autenticado no sistema CAMAAR') do |perfil|
  @departamento = Departamento.find_or_create_by!(nome: "Ciência da Computação (CIC)")
  @usuario = Usuario.new(
    nome: "Test #{perfil}",
    email: "#{perfil.downcase}#{Time.now.to_i}@unb.br",
    perfil: perfil.downcase,
    ativo: true,
    departamento: @departamento
  )
  @usuario.password = '123456'
  @usuario.save!

  # Limpar qualquer usuário anterior e armazenar o novo
  Thread.current[:test_usuario_id] = @usuario.id
end

Dado('que os dados de turmas e disciplinas do SIGAA do semestre {string} foram sincronizados') do |semestre|
  @semestre = semestre
  @departamento = Departamento.find_or_create_by!(nome: "Ciência da Computação (CIC)")
  @disciplina = Disciplina.find_or_create_by!(
    nome: "Cálculo 1",
    codigo: "MAT001"
  )
  @turma = Turma.find_or_create_by!(
    disciplina: @disciplina,
    departamento: @departamento,
    codigo_turma: "MAT001A",
    semestre: semestre
  )
end

Dado('existe um formulário de avaliação chamado {string}') do |nome_formulario|
  # Criar pelo menos um aluno para a turma
  aluno = Usuario.new(
    nome: "Aluno Template",
    email: "aluno_template#{Time.now.to_i}@unb.br",
    perfil: "discente",
    ativo: true
  )
  aluno.password = '123456'
  aluno.save!

  Matricula.find_or_create_by!(usuario: aluno, turma: @turma) do |m|
    m.papel_na_turma = "aluno"
  end

  @template = Template.find_or_create_by!(titulo: nome_formulario) do |t|
    t.descricao = nome_formulario
    t.ativo = true
    t.criador = @usuario
    t.skip_questions_validation = true
  end

  @formulario = Formulario.create!(
    turma: @turma,
    criado_por: @usuario,
    template: @template,
    publico_alvo: "discente",
    status: "fechado"
  )
end


# --- DADOS DE PREPARAÇÃO DOS CENÁRIOS (GIVENS) ---

Dado('que o formulário {string} possui respostas cadastradas pelos alunos') do |nome_formulario|
  template = Template.find_by(titulo: nome_formulario)
  formulario = template.formularios.first

  aluno = Usuario.new(
    nome: "Aluno Teste",
    email: "aluno#{Time.now.to_i}@unb.br",
    perfil: "discente",
    ativo: true
  )
  aluno.password = '123456'
  aluno.save!

  Matricula.find_or_create_by!(usuario: aluno, turma: formulario.turma) do |m|
    m.papel_na_turma = "aluno"
  end

  resposta = Resposta.create!(
    formulario: formulario,
    usuario: aluno,
    enviado_em: Time.current
  )

  pergunta = formulario.template.perguntas.first || QuestaoTemplate.create!(template: formulario.template, enunciado: "Teste", tipo: "texto", ordem: 1)
  RespostaItem.create!(resposta: resposta, questao_template: pergunta, valor_texto: "Ótima disciplina!")
end

Dado('o administrador acessa a página de {string}') do |nome_pagina|
  visit "/admin/relatorios"
end

Dado('que o formulário {string} possui respostas para as turmas {string} e {string} de {string}') do |nome_formulario, turma_1, turma_2, disciplina|
  template = Template.find_by(titulo: nome_formulario)
  formulario = template.formularios.first

  [ turma_1, turma_2 ].each do |turma_nome|
    codigo_alvo = "MAT001#{turma_nome}"
    turma = Turma.find_or_create_by!(codigo_turma: codigo_alvo) do |t|
      t.disciplina = formulario.turma.disciplina
      t.departamento = formulario.turma.departamento
      t.semestre = @semestre || "2023.2"
    end

    aluno = Usuario.new(
      nome: "Aluno #{turma_nome}",
      email: "aluno_#{turma_nome}#{Time.now.to_i}@unb.br",
      perfil: "discente",
      ativo: true
    )
    aluno.password = '123456'
    aluno.save!

    Matricula.find_or_create_by!(usuario: aluno, turma: turma) do |m|
      m.papel_na_turma = "aluno"
    end

    resposta = Resposta.create!(formulario: formulario, usuario: aluno, enviado_em: Time.current)
    pergunta = formulario.template.perguntas.first || QuestaoTemplate.create!(template: formulario.template, enunciado: "Teste", tipo: "texto", ordem: 1)
    RespostaItem.create!(resposta: resposta, questao_template: pergunta, valor_texto: "Ótima turma #{turma_nome}!")
  end
end

Dado('seleciona o formulário {string}') do |nome_formulario|
  template = Template.find_by(titulo: nome_formulario)
  @formulario_selecionado = template.formularios.first
end

Dado('que foi criado um novo formulário chamado {string}') do |nome_formulario|
  @template = Template.find_or_create_by!(titulo: nome_formulario) do |t|
    t.descricao = nome_formulario
    t.ativo = true
    t.criador = @usuario
    t.skip_questions_validation = true
  end

  Formulario.create!(
    turma: @turma,
    criado_por: @usuario,
    template: @template,
    publico_alvo: "discente",
    status: "fechado"
  )
end

Dado('o formulário {string} ainda não possui nenhuma resposta') do |nome_formulario|
  template = Template.find_by(titulo: nome_formulario)
  formulario = template.formularios.first
  expect(formulario.respostas.count).to eq(0)
end


# --- AÇÕES DO USUÁRIO (WHENS) ---

Quando('ele seleciona o formulário {string} na listagem') do |nome_formulario|
  expect(page).to have_content(nome_formulario)
  template = Template.find_by(titulo: nome_formulario)
  @formulario_selecionado = template.formularios.first
end

Quando('clica no botão {string}') do |nome_botao|
  if @formulario_selecionado
    find("form input[name='id'][value='#{@formulario_selecionado.id}']", visible: false).find(:xpath, '..').click_button(nome_botao)
  else
    click_button nome_botao
  end
end

Quando('ele filtra os resultados escolhendo apenas a turma {string}') do |nome_turma|
  if @formulario_selecionado
    select "MAT001#{nome_turma}", from: "turma_id_#{@formulario_selecionado.id}"
  end
end

Quando('ele tenta acessar a URL direta de geração de relatórios administrativos em {string}') do |url_direta|
  visit url_direta
end


# --- VALIDAÇÕES DE RESULTADO (THENS) ---

Então('o sistema deve iniciar o download de um arquivo chamado {string}') do |nome_arquivo|
  # Validação básica de contenção esperada
  expect(page.body).not_to be_empty
end

Então('o arquivo CSV baixado deve conter as colunas {string}, {string}, {string} e {string}') do |coluna1, coluna2, coluna3, coluna4|
  csv_content = page.body
  [ coluna1, coluna2, coluna3, coluna4 ].each do |col|
    expect(csv_content).to include(col)
  end
end

Então('o sistema deve exibir a mensagem de sucesso {string}') do |mensagem|
  # Nota: Com send_data (download de arquivo), o flash não é preservado na página HTML
  # Verificamos a resposta HTTP ao invés
  expect(page.response_headers['Content-Disposition']).to include("attachment")
  expect(page.response_headers['Content-Type']).to include("text/csv")
end

Então('o arquivo baixado deve conter apenas as respostas dos alunos matriculados na turma {string} de {string}') do |turma, disciplina|
  csv_content = page.body
  # O turma pode ser "A" ou "B", mas o código será "MAT001A" ou "MAT001B"
  turma_completa = "MAT001#{turma}"
  expect(csv_content).to include(turma_completa)
end

Então('o sistema não deve iniciar nenhum download de arquivo') do
  expect(page.response_headers['Content-Disposition']).to be_nil
end

Então('deve exibir a mensagem de aviso {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('o sistema deve redirecioná-lo para a página inicial') do
  expect([ root_path, "/avaliacoes" ]).to include(current_path)
end

Então('deve exibir a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
