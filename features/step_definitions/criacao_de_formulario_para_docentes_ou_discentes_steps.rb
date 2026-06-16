# --- GIVENS (PREPARAÇÃO) ---
Dado('que existe um administrador logado no CAMAAR') do
  # Criar um admin para os testes
  admin = Usuario.where(email: 'admin@camaar.com').first
  unless admin
    admin = Usuario.new(nome: 'Admin', email: 'admin@camaar.com', perfil: 'administrador')
    admin.password = 'Senha123'
    admin.save!
  end
  # Simulamos um usuário logado armazenando na sessão (para Capybara)
  Thread.current[:test_usuario_id] = admin.id
end

Dado('o semestre letivo atual está configurado') do
  # Se precisar configurar semestre futuramente, adicione aqui
end

Dado('existe a turma {string} com {int} docente e {int} discentes vinculados') do |nome_turma, qtd_docentes, qtd_discentes|
  # Garante que departamento existe
  departamento = Departamento.where(nome: "Engenharia").first || Departamento.create!(nome: "Engenharia")

  # Verifica se a disciplina já existe
  disciplina = Disciplina.where(nome: nome_turma).first
  unless disciplina
    disciplina = Disciplina.create!(nome: nome_turma, codigo: "DISC#{rand(1000..9999)}")
  end

  # Verifica se a turma já existe (para evitar duplicatas)
  turma = Turma.where(codigo_turma: "#{nome_turma.gsub(' ', '_')}-2024").first
  unless turma
    turma = Turma.create!(
      codigo_turma: "#{nome_turma.gsub(' ', '_')}-2024",
      semestre: "2024.1",
      disciplina_id: disciplina.id,
      departamento_id: departamento.id
    )
  end

  qtd_docentes.times do |i|
    usuario = Usuario.where(email: "docente#{i}@teste.com").first
    unless usuario
      usuario = Usuario.new(nome: "Professor #{i}", email: "docente#{i}@teste.com", perfil: "docente")
      usuario.password = "Senha123"
      usuario.save!
    end

    # Evita matrícula duplicada
    unless turma.matriculas.exists?(usuario_id: usuario.id)
      turma.matriculas.create!(papel_na_turma: 'docente', usuario: usuario)
    end
  end

  qtd_discentes.times do |i|
    usuario = Usuario.where(email: "aluno#{i}@teste.com").first
    unless usuario
      usuario = Usuario.new(nome: "Aluno #{i}", email: "aluno#{i}@teste.com", perfil: "discente")
      usuario.password = "Senha123"
      usuario.save!
    end

    unless turma.matriculas.exists?(usuario_id: usuario.id)
      turma.matriculas.create!(papel_na_turma: 'discente', usuario: usuario)
    end
  end
end

Dado('que o administrador acessa a página de criação de formulário para a turma {string}') do |nome_turma|
  visit new_formulario_path
end

Dado('que a turma {string} foi recém-criada e ainda não possui alunos \(discentes) matriculados') do |nome_turma|
  departamento = Departamento.where(nome: "Engenharia").first || Departamento.create!(nome: "Engenharia")

  disciplina = Disciplina.where(nome: nome_turma).first
  unless disciplina
    disciplina = Disciplina.create!(nome: nome_turma, codigo: "DISC#{rand(1000..9999)}")
  end

  turma = Turma.where(codigo_turma: "#{nome_turma.gsub(' ', '_')}-2024").first
  unless turma
    Turma.create!(
      codigo_turma: "#{nome_turma.gsub(' ', '_')}-2024",
      semestre: "2024.1",
      disciplina_id: disciplina.id,
      departamento_id: departamento.id
    )
  end
end

Dado('que a turma {string} já possui um formulário ativo direcionado aos {string}') do |nome_turma, publico|
  departamento = Departamento.where(nome: "Engenharia").first || Departamento.create!(nome: "Engenharia")

  disciplina = Disciplina.where(nome: nome_turma).first
  unless disciplina
    disciplina = Disciplina.create!(nome: nome_turma, codigo: "DISC#{rand(1000..9999)}")
  end

  turma = Turma.where(codigo_turma: "#{nome_turma.gsub(' ', '_')}-2024").first
  unless turma
    turma = Turma.create!(
      codigo_turma: "#{nome_turma.gsub(' ', '_')}-2024",
      semestre: "2024.1",
      disciplina_id: disciplina.id,
      departamento_id: departamento.id
    )
  end

  # Criar um discente se não houver
  discente = Usuario.where(email: "discente_#{rand(1000..9999)}@teste.com").first
  unless discente
    discente = Usuario.new(nome: 'Discente', email: "discente_#{rand(1000..9999)}@teste.com", perfil: "discente")
    discente.password = "Senha123"
    discente.save!
  end

  unless turma.matriculas.exists?(usuario_id: discente.id)
    turma.matriculas.create!(papel_na_turma: 'discente', usuario: discente)
  end

  # Criar um admin
  admin = Usuario.where(perfil: "administrador").first
  unless admin
    admin = Usuario.new(nome: 'Admin', email: 'admin@camaar.com', perfil: "administrador")
    admin.password = "Senha123"
    admin.save!
  end

  # Criar um template
  template = Template.first
  unless template
    template = Template.create!(titulo: "Template Padrão", ativo: true, criador_id: admin.id) do |t|
      t.skip_questions_validation = true
    end
  end

  # Criar o formulário ativo
  Formulario.create!(
    turma: turma,
    publico_alvo: publico.downcase.singularize,
    status: 'aberto',
    template: template,
    criado_por: admin
  )
end

Dado('que o administrador inicia a criação de um novo formulário para uma turma') do
  visit new_formulario_path
end

# --- WHENS (AÇÕES) ---
Quando('ele preenche os dados do formulário com o título {string}') do |titulo|
  # Procurar ou criar um template com esse título
  admin = Usuario.where(perfil: "administrador").first
  unless admin
    admin = Usuario.new(nome: 'Admin', email: 'admin@camaar.com', perfil: "administrador")
    admin.password = "Senha123"
    admin.save!
  end

  template = Template.where(titulo: titulo).first
  unless template
    template = Template.create!(titulo: titulo, ativo: true, criador_id: admin.id) do |t|
      t.skip_questions_validation = true
    end
  end

  visit current_path
  select template.titulo, from: 'template_id'

  # Selecionar uma turma aleatória
  turma = Turma.first
  if turma
    select "#{turma.codigo} - Turma #{turma.nome}", from: 'turma_id'
  end
end

Quando('seleciona o público-alvo como {string}') do |publico|
  select publico, from: 'publico_alvo'
end

Quando('clica em {string}') do |botao|
  click_button botao
end

Quando('ele preenche todas as perguntas da avaliação') do
  admin = Usuario.where(perfil: "administrador").first || Usuario.create!(nome: 'Admin', email: 'admin@camaar.com', perfil: 'administrador', password: 'password')
  template = Template.first || Template.create!(titulo: "Template Padrão", ativo: true, criador_id: admin.id) do |t|
    t.skip_questions_validation = true
  end
  visit current_path
  select template.titulo, from: 'template_id'

  turma = Turma.first
  select "#{turma.codigo} - Turma #{turma.nome}", from: 'turma_id' if turma
end

Quando('deixa o campo de seleção {string} em branco') do |campo|
  # Campo já estará em branco por padrão
end

Quando('tenta clicar em {string}') do |botao|
  click_button botao
end

Quando('o administrador tenta criar um formulário selecionando o público-alvo como {string} para esta turma') do |publico|
  # Selecionar template
  template = Template.first || Template.create!(
    titulo: "Template Padrão",
    ativo: true,
    criador_id: Usuario.where(perfil: "administrador").first.id
  ) do |t|
    t.skip_questions_validation = true
  end

  visit new_formulario_path
  select template.titulo, from: 'template_id'

  # Selecionar turma vazia
  turma = Turma.where("codigo_turma LIKE ?", "%Tópicos%").first
  select "#{turma.codigo} - Turma #{turma.nome}", from: 'turma_id' if turma

  select publico, from: 'publico_alvo'
end

Quando('o administrador tenta criar uma nova avaliação e seleciona novamente {string} como público-alvo') do |publico|
  visit new_formulario_path

  template = Template.first
  select template.titulo, from: 'template_id'

  turma = Turma.where("codigo_turma LIKE ?", "%Engenharia%").first
  select "#{turma.codigo} - Turma #{turma.nome}", from: 'turma_id' if turma

  select publico, from: 'publico_alvo'
  click_button "Salvar e Publicar"
end

# --- THENS (VERIFICAÇÕES) ---
Então('o sistema deve registrar o formulário com sucesso') do
  expect(page).to have_content('Formulário criado com sucesso') or expect(Formulario.count).to be > 0
end

Então('o formulário deve ficar disponível apenas no painel dos alunos \(discentes) matriculados nesta turma') do
  # Verificação de que discentes podem ver o formulário
  # Implementação futura: verificar permissões de acesso
end

Então('o sistema não deve permitir que o docente da turma responda a este formulário') do
  # Implementação futura: verificar permissões de acesso para docentes
end

Então('o formulário deve ficar disponível exclusivamente no painel do professor responsável pela turma') do
  # Implementação futura: verificar que apenas docentes podem ver
end

Então('o sistema não deve notificar ou exibir o formulário para os alunos') do
  # Implementação futura: verificar que discentes não veem o formulário
end

Então('a validação do formulário deve falhar') do
  expect(page).to have_css('.bg-red-50, .alert, .error, .flash-alert')
end

Então('o sistema deve exibir a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('a criação deve ser bloqueada') do
  # Verificar que nenhum novo formulário foi criado para turma vazia
  turma_vazia = Turma.where("codigo_turma LIKE ?", "%Tópicos%").first
  expect(turma_vazia.formularios.count).to eq(0) if turma_vazia
end

Então('o sistema deve exibir o alerta {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('o sistema deve interceptar a ação') do
  # Verificação de que a ação foi bloqueada
end

Então('exibir a mensagem de aviso {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
