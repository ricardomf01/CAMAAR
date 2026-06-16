# encoding: utf-8
# frozen_string_literal: true

# Step definitions para a issue #109 - Visualização de formulários para responder.
# As definições abaixo cobrem todos os passos declarados em
# features/formulario/visualizacao_formularios.feature, porém a
# implementação interna foi propositalmente omitida. Cada bloco encerra com
# uma expectativa que falha de propósito, para que o Cucumber sinalize os
# cenários como "failed" (vermelho) até que a implementação real seja
# escrita.

Dado('que eu sou um "usuarios" com "perfil" "discente" e possuo uma "matriculas" na "turmas" "CIC0105"') do
  expect(true).to be(false)
end

Dado('existe um "formularios" direcionado à minha turma onde o "status" é "aberto" e o "publico_alvo" é "discente"') do
  expect(true).to be(false)
end

Dado('a data atual está entre a "data_inicio" e a "data_limite"') do
  expect(true).to be(false)
end

Dado('eu não possuo nenhum registro correspondente na tabela "respostas" para este formulário') do
  expect(true).to be(false)
end

Quando('eu entro na rota de listagem de avaliações pendentes') do
  expect(true).to be(false)
end

Então('a view deve exibir as informações do formulário e o "codigo_turma" da turma correspondente') do
  expect(true).to be(false)
end

Dado('que o "formularios" da minha turma possui uma "data_limite" definida no passado') do
  expect(true).to be(false)
end

Então('a página não deve listar este formulário como disponível para preenchimento') do
  expect(true).to be(false)
end

Dado('que existe um "formularios" com "status" "aberto" para a turma "TA"') do
  expect(true).to be(false)
end

Dado('eu não possuo um registro correspondente na tabela "matriculas" vinculando meu "usuario_id" ao "turma_id" daquela turma') do
  expect(true).to be(false)
end

Quando('eu forço o acesso à listagem de avaliações') do
  expect(true).to be(false)
end

Então('a view deve exibir a mensagem "Você não possui formulários pendentes para responder no momento"') do
  expect(true).to be(false)
end
