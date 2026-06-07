Dado('que estou na página de criação de templates') do
  visit templates_path
end

Quando('adiciono a questão {string} do tipo {string}') do |text, type|
  all('input[name="template[perguntas][][texto]"]').last.set(text)
  all('select[name="template[perguntas][][tipo]"]').last.select(type == "Múltipla Escolha" ? "Escala Likert (1 a 5)" : "Texto Livre / Comentário")
end

Então('o template {string} deve constar no sistema') do |title|
  expect(Template.exists?(titulo: title)).to be true
end

Então('nenhum template novo deve ser salvo no sistema') do
end
