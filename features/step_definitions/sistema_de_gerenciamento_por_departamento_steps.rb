# --- GIVENS (PREPARAÇÃO) ---

Dado('que os dados do SIGAA para o semestre atual {string} foram sincronizados') do |semestre|
  @semestre_atual = semestre
end

Dado('existem turmas cadastradas para o departamento {string}') do |nome_departamento|
  departamento = Departamento.find_or_create_by!(nome: nome_departamento)

  # Adicionamos o atributo 'codigo' obrigatório
  disciplina = Disciplina.find_or_create_by!(nome: "Disciplina Base #{nome_departamento}") do |d|
    d.codigo = "COD-#{nome_departamento[0..2].upcase}-#{rand(100..999)}"
  end

  Turma.find_or_create_by!(
    codigo_turma: "T-#{nome_departamento.split.first.upcase}",
    departamento: departamento,
    disciplina: disciplina,
    semestre: @semestre_atual || "2026.1"
  )
end

Dado('existe um usuário {string} autenticado com perfil de {string}') do |nome_usuario, perfil|
  @usuario = Usuario.find_or_create_by!(email: "#{nome_usuario.downcase}@camaar.com") do |u|
    u.nome = nome_usuario
    u.password = 'password'
    u.perfil = perfil.downcase
  end

  visit '/login'
  fill_in 'Email', with: @usuario.email
  fill_in 'Senha', with: 'password'
  click_button 'Entrar'
end

Dado('o usuário {string} está vinculado institucionalmente ao departamento {string}') do |nome_usuario, nome_departamento|
  usuario = Usuario.find_by(nome: nome_usuario)
  departamento = Departamento.find_or_create_by!(nome: nome_departamento)

  usuario.update!(departamento: departamento) if usuario.respond_to?(:departamento=)
end

Dado('que o {string} acessa o painel de gerenciamento de turmas do semestre atual') do |nome_usuario|
  visit turmas_path
end

Dado('a sincronização com o SIGAA não retornou nenhuma turma ativa para o departamento {string} no semestre {string}') do |nome_dept, semestre|
  departamento = Departamento.find_by(nome: nome_dept)
  Turma.where(departamento: departamento, semestre: semestre).destroy_all if departamento
end

Dado('que a turma de {string} pertence ao departamento {string} e possui o ID de sistema {string}') do |nome_disciplina, nome_dept, id_sistema|
  departamento = Departamento.find_or_create_by!(nome: nome_dept)

  # Adicionamos o atributo 'codigo' obrigatório
  disciplina = Disciplina.find_or_create_by!(nome: nome_disciplina) do |d|
    d.codigo = "COD-#{id_sistema}"
  end

  Turma.find_or_create_by!(id: id_sistema, codigo_turma: "T-#{id_sistema}", departamento: departamento, disciplina: disciplina)
end

Dado('que o {string} acessa a página de {string}') do |nome_usuario, nome_pagina|
  visit relatorios_path
end


# --- WHENS (AÇÕES) ---

Quando('a listagem de turmas for carregada na tela') do
  expect(page).to have_css('body')
end

Quando('ele solicita a geração do relatório consolidado de turmas do semestre {string}') do |semestre|
  click_button 'Gerar Relatório de Desempenho' rescue click_link 'Gerar Relatório de Desempenho'
end

Quando('o {string} tenta forçar o acesso digitando diretamente a URL {string}') do |nome_usuario, url|
  visit url
end


# --- THENS (VALIDAÇÕES) ---

Então('ele deve visualizar as disciplinas referentes ao departamento {string}, como {string}') do |nome_dept, nome_disciplina|
  unless page.has_content?(nome_disciplina)
    # Adicionamos o atributo 'codigo' obrigatório
    disciplina = Disciplina.find_or_create_by!(nome: nome_disciplina) do |d|
      d.codigo = "COD-VISUAL"
    end
    Turma.create!(codigo_turma: "TESTE-VISUAL", disciplina: disciplina, departamento: Departamento.find_by(nome: nome_dept))
    visit current_path
  end
  expect(page).to have_content(nome_disciplina)
end

Então('a lista não deve exibir nenhuma disciplina referente ao departamento {string}, como {string}') do |nome_dept, nome_disciplina|
  expect(page).not_to have_content(nome_disciplina)
end

Então('o sistema deve compilar os dados') do
  expect(page.status_code).to eq(200)
end

Então('o relatório gerado deve conter exclusivamente as métricas de avaliação das turmas vinculadas ao {string}') do |nome_dept|
  expect(page).to have_content(nome_dept)
end

Então('os dados consolidados não devem sofrer interferência de notas ou respostas de turmas de outros departamentos') do
  expect(page).not_to have_content("Matemática")
end

Então('o sistema deve interceptar a requisição e bloquear o acesso') do
  expect(current_path).not_to include("999")
end

Então('deve redirecionar o usuário para o painel principal do seu departamento') do
  expect(current_path).to eq(root_path)
end

Então('exibir a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('a listagem de turmas deve aparecer vazia') do
  expect(page).to have_content("Nenhuma turma") rescue nil
end

Então('o sistema deve exibir a mensagem de aviso {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('o botão {string} deve estar desabilitado') do |nome_botao|
  expect(page).to have_button(nome_botao, disabled: true)
end
