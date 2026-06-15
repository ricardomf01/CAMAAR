# encoding: utf-8
# frozen_string_literal: true

# Step definitions para a issue #103 - Criar formulário de avaliação.
# As definições abaixo cobrem todos os passos declarados em
# features/formulario/criar_formulario_avaliacao.feature, porém a
# implementação interna foi propositalmente omitida. Cada bloco encerra com
# uma expectativa que falha de propósito, para que o Cucumber sinalize os
# cenários como "failed" (vermelho) até que a implementação real seja
# escrita.

Dado('que eu estou logado como um "usuarios" cujo "perfil" é "administrador"') do
  expect(true).to be(false)
end

Dado('existe um "templates" ativo com "titulo" "Avaliação Semestral CIC"') do
  expect(true).to be(false)
end

Dado('existe uma "turmas" cadastrada com "codigo_turma" "TA" e "semestre" "2026.1"') do
  expect(true).to be(false)
end

Quando('preencho os campos do novo formulário selecionando o template e a turma') do
  expect(true).to be(false)
end

Quando('defino o "publico_alvo" como "discente"') do
  expect(true).to be(false)
end

Quando('defino a "data_inicio" para hoje e "data_limite" para daqui a 15 dias') do
  expect(true).to be(false)
end

Quando('defino o "status" como "aberto"') do
  expect(true).to be(false)
end

Quando('clico em "Criar Formulário"') do
  expect(true).to be(false)
end

Então('o sistema deve persistir um novo registro na tabela "formularios" vinculando o "criado_por_id" ao meu ID de usuário') do
  expect(true).to be(false)
end

Dado('que eu estou logado como um "usuarios" com "perfil" "administrador"') do
  expect(true).to be(false)
end

Quando('tento criar um "formularios" configurando a "data_limite" para um momento anterior à "data_inicio"') do
  expect(true).to be(false)
end

Então('o model de "formularios" deve falhar nas validações de data') do
  expect(true).to be(false)
end

Então('o registro não deve ser inserido no banco de dados') do
  expect(true).to be(false)
end

Quando('tento criar um "formularios" passando uma string de 50 caracteres para o campo "publico_alvo"') do
  expect(true).to be(false)
end

Então('o sistema deve barrar a requisição antes de violar o limite do banco de dados \\("publico_alvo" limit: 20\\)') do
  expect(true).to be(false)
end

Então('deve retornar um erro de comprimento de caracteres "Público alvo inválido ou muito longo"') do
  expect(true).to be(false)
end

Dado('que existe um "templates" onde o atributo "ativo" é falso') do
  expect(true).to be(false)
end

Quando('o administrador tenta criar um "formularios" apontando para o "template_id" desse template desativado') do
  expect(true).to be(false)
end

Então('o sistema deve impedir a criação exibindo o alerta "Não é possível publicar formulários usando templates inativos"') do
  expect(true).to be(false)
end
