# frozen_string_literal: true

RSpec.describe Kennel::Domain::Medical::ConditionCatalog do
  describe '.fetch' do
    it '既知のキーで病気を返すこと(:hip_dysplasiaは慢性)' do
      expect(described_class.fetch(:hip_dysplasia).chronic?).to be(true)
    end

    it '未知のキーでは例外を投げること' do
      expect { described_class.fetch(:unknown) }.to raise_error(ArgumentError)
    end
  end
end
