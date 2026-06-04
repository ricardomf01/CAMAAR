require 'csv'

class Formulario < ApplicationRecord
  # ... suas associações existentes (belongs_to, has_many, etc.) ...

  def self.to_csv(formularios)
    CSV.generate(headers: true, col_sep: ",", encoding: "UTF-8") do |csv|
      csv << ["Matrícula", "Turma", "Disciplina", "Respostas"]

      # Otimização: Carrega os dados relacionados em lote para evitar consultas repetitivas
      formularios.each do |form|
        form.respostas.each do |resp|
          resp.resposta_itens.each do |item|
            valor_resposta = item.questao_template.tipo == "likert" ? item.valor_numerico.to_s : item.valor_texto

            csv << [
              resp.usuario&.matricula || "Anônimo",
              form.turma.codigo_turma,
              form.turma.disciplina.nome,
              valor_resposta
            ]
          end
        end
      end
    end
  end
end
