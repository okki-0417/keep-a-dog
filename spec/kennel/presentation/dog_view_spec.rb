# frozen_string_literal: true

RSpec.describe Kennel::Presentation::DogView do
  def dog
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: 400)
  end

  describe '.render' do
    it '健康な犬は犬種・体型・健康「良好」を表示すること' do
      expect(described_class.render(dog)).to include('柴犬', '体型スコア', '良好')
    end

    it '病気の犬は病名を表示すること' do
      d = dog
      d.fall_ill(Kennel::Domain::Medical::ConditionCatalog.fetch(:hip_dysplasia))
      expect(described_class.render(d)).to include('股関節形成不全')
    end

    it '亡くなった犬は虹の橋の表示になること' do
      d = dog
      d.pass_day(6_000) # 寿命超過で老衰
      expect(described_class.render(d)).to include('虹の橋')
    end
  end

  describe '.gauges' do
    it '空腹・信頼・社会化・水分のバーと体重を返すこと' do
      expect(described_class.gauges(dog)).to include(a_string_including('空腹'), a_string_including('水分'), a_string_including('体重'))
    end
  end

  describe '.flags' do
    it '十分に世話された犬では注意サインが空であること' do
      d = dog
      d.exercise(60) # 必要量を満たし運動不足を解消
      expect(described_class.flags(d)).to be_empty
    end

    it '脱水・運動不足などの注意サインを拾うこと' do
      d = dog
      d.lose_water(50)
      expect(described_class.flags(d)).to include('脱水ぎみ', '運動不足')
    end
  end

  describe '.headline' do
    it '犬種とライフステージを一行で返すこと' do
      expect(described_class.headline(dog)).to include('柴犬', '成犬')
    end
  end
end
