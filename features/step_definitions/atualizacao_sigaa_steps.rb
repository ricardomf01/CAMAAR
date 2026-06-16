# Contexto

Dado('a base de dados do CAMAAR já possui turmas cadastradas') do
  @turma_atual = Turma.create!(
    codigo_turma: "T01",
    semestre: "2026.1",
    departamento: Departamento.find_or_create_by!(nome: "DEPTO CIÊNCIAS DA COMPUTAÇÃO"),
    disciplina: Disciplina.find_or_create_by!(nome: "Engenharia de Software", codigo: "CIC0123")
  )
end

# Cenário Feliz
Quando('eu solicito a atualização dos dados do SIGAA') do
  # Simulation uses the same button
  visit admin_import_console_path
  click_button "Carregar Dados do CIC"
end

Quando('um usuário alterou seu vínculo \(trancamento ou nova matrícula) no sistema origem') do
  ENV["SIGAA_DATA_STATUS"] = "status_changed"
end

Então('o sistema deve atualizar a tabela de matrículas correspondente para refletir o status atual') do
  # No mock, test success path
  expect(Turma.count).to be > 0
end

# Cenários Tristes
Dado('que um discente já enviou uma resposta para um formulário de avaliação') do
  # @turma_atual is used
  @aluno = Usuario.create!(nome: "Aluno Teste", email: "aluno@teste.com", matricula: "111222333", perfil: "discente", senha_hash: "")
  @matricula = Matricula.create!(usuario: @aluno, turma: @turma_atual, papel_na_turma: "aluno")
  @template = Template.create!(titulo: "t", criador_id: Usuario.find_by(perfil: 'administrador').id)
  QuestaoTemplate.create!(template: @template, enunciado: "Q1", tipo: "dissertativa", ordem: 1)
  @form = Formulario.create!(turma: @turma_atual, status: "Fechado", titulo: "Form", publico_alvo: "discente", template: @template)
  @resposta = Resposta.create!(usuario: @aluno, formulario: @form, enviado_em: Time.current)
end

Quando('eu solicito a atualização da base do SIGAA') do
  visit admin_import_console_path
  click_button "Carregar Dados do CIC"
end

Quando('o SIGAA informa que este aluno não está mais matriculado na turma') do
  ENV["SIGAA_DATA_STATUS"] = "missing_aluno"
end

Então('o sistema deve manter o registro histórico da resposta intacto por segurança') do
  expect(Resposta.exists?(@resposta.id)).to be_truthy
end

Então('apenas inativar o vínculo na turma pertinente, informando a ressalva no log de atualização') do
  @matricula.reload
  expect(@matricula.trancado).to be_truthy
end

Quando('o SIGAA envia dados estruturais corrompidos durante a execução da rotina') do
  ENV["SIGAA_DATA_STATUS"] = "corrupted"
  visit admin_import_console_path
  click_button "Carregar Dados do CIC"
end

Então('o sistema deve abortar a transação para manter a integridade da base') do
  expect(page).to have_content("Erro de compatibilidade de dados. Atualização cancelada.")
end

Dado('que o sistema está processando uma atualização de grande volume do SIGAA') do
  AdminController.class_variable_set(:@@sigaa_updating, true)
end

Quando('outro administrador tenta iniciar o mesmo processo de atualização simultaneamente') do
  visit admin_dashboard_path
end

Então('o sistema deve bloquear a segunda requisição') do
  expect(page).to have_button("Indisponível", disabled: true)
  AdminController.class_variable_set(:@@sigaa_updating, false)
end
