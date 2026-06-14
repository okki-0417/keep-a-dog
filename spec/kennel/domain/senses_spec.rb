# frozen_string_literal: true

RSpec.describe Kennel::Domain::Senses do
  describe '.color_vision' do
    it ':dichromatic を返すこと' do
      expect(described_class.color_vision).to eq(:dichromatic)
    end
  end

  describe '.sees_color?' do
    it '青・黄は true、それ以外(赤)は false を返すこと' do
      expect([described_class.sees_color?(:blue), described_class.sees_color?(:yellow), described_class.sees_color?(:red)])
        .to eq([true, true, false])
    end
  end

  describe '.hears_frequency?' do
    it '可聴域(67〜45000Hz)の内は true、外は false を返すこと' do
      flags = [
        described_class.hears_frequency?(67), described_class.hears_frequency?(45_000),
        described_class.hears_frequency?(50), described_class.hears_frequency?(60_000)
      ]
      expect(flags).to eq([true, true, false, false])
    end
  end

  describe '.smell_sensitivity_factor' do
    it '正の倍率を返すこと' do
      expect(described_class.smell_sensitivity_factor).to be_positive
    end
  end
end
