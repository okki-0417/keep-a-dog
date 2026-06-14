# frozen_string_literal: true

RSpec.describe Kennel::Domain::Dog::AgeInDays do
  describe '.new' do
    it '負の日齢では生成できないこと' do
      expect { described_class.new(-1) }.to raise_error(ArgumentError)
    end

    it '整数でない日齢では生成できないこと' do
      expect { described_class.new(1.5) }.to raise_error(ArgumentError)
    end
  end

  describe '#advanced_by' do
    it '日数を加えた新しい値を返すこと(100→105)' do
      expect(described_class.new(100).advanced_by(5).days).to eq(105)
    end

    it '元の値オブジェクトは変化しないこと(不変)' do
      age = described_class.new(100)
      age.advanced_by(5)
      expect(age.days).to eq(100)
    end

    it '負の日数では進められないこと(加齢は逆行しない)' do
      expect { described_class.new(100).advanced_by(-1) }.to raise_error(ArgumentError)
    end
  end
end
