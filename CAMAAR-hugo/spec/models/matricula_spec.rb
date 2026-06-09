require 'rails_helper'

RSpec.describe Matricula, type: :model do
  describe 'associations' do
    it 'belongs to turma' do
      assoc = described_class.reflect_on_association(:turma)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'belongs to usuario' do
      assoc = described_class.reflect_on_association(:usuario)
      expect(assoc.macro).to eq :belongs_to
    end
  end
end
