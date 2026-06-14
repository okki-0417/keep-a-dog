# frozen_string_literal: true

RSpec.describe Kennel::Domain::Breed::BreedCatalog do
  describe '.fetch' do
    it '既知のキーで犬種を返すこと' do
      expect(described_class.fetch(:shiba).name).to eq('柴犬')
    end

    it '未知のキーでは例外を投げること' do
      expect { described_class.fetch(:wolf) }.to raise_error(ArgumentError)
    end
  end
end
