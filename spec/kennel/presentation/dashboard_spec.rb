# frozen_string_literal: true

RSpec.describe Kennel::Presentation::Dashboard do
  let(:pastel) { Pastel.new(enabled: false) }

  def dog
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: 400)
  end

  describe '.render' do
    it '見出し・ゲージ・日誌が描かれること' do
      output = described_class.render(dog: dog, diary: ['水をあげた'], pastel: pastel)
      expect(output).to include('柴犬', '空腹', '水をあげた')
    end

    it '日誌が空なら「まだ記録なし」と出ること' do
      expect(described_class.render(dog: dog, pastel: pastel)).to include('まだ記録なし')
    end

    it '注意があれば警告として描かれること' do
      output = described_class.render(dog: dog, pastel: pastel, notice: '犬がいません')
      expect(output).to include('⚠', '犬がいません')
    end

    it '注意サインのある犬は枠内に表示されること' do
      d = dog
      d.lose_water(50) # 脱水
      expect(described_class.render(dog: d, pastel: pastel)).to include('脱水ぎみ')
    end

    it '亡くなった犬は旅立ちの姿で描かれること' do
      d = dog
      d.pass_day(6_000)
      expect(described_class.render(dog: d, pastel: pastel)).to include('旅立ち')
    end
  end
end
