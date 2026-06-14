# frozen_string_literal: true

RSpec.describe Kennel::Domain::Dog::Death do
  describe '#label' do
    it '死因の和名を返すこと(:old_age→老衰)' do
      expect(described_class.new(cause: :old_age).label).to eq('老衰')
    end
  end

  describe '.new' do
    it '未知の死因では生成できないこと' do
      expect { described_class.new(cause: :explosion) }.to raise_error(ArgumentError)
    end
  end
end
