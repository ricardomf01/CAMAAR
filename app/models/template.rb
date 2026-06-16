class Template < ApplicationRecord
  has_many :perguntas, class_name: "QuestaoTemplate", dependent: :destroy
  has_many :formularios, dependent: :destroy
  belongs_to :criador, class_name: "Usuario", foreign_key: "criador_id"
end
