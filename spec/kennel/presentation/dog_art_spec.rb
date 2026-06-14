# frozen_string_literal: true

RSpec.describe Kennel::Presentation::DogArt do
  def dog(age_in_days: 730)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: age_in_days)
  end

  describe '.mood' do
    it '亡くなった犬は旅立ちになること' do
      d = dog
      d.pass_day(6_000)
      expect(described_class.mood(d)).to eq(:memorial)
    end

    it '病気の犬はぐったりになること' do
      d = dog
      d.fall_ill(Kennel::Domain::Medical::ConditionCatalog.fetch(:atopy))
      expect(described_class.mood(d)).to eq(:sick)
    end

    it '不安の強い犬はけいかいになること' do
      d = dog
      d.left_alone(8) # 許容を超える留守番で分離不安
      expect(described_class.mood(d)).to eq(:wary)
    end

    it '脱水した犬はしょんぼりになること' do
      d = dog
      d.lose_water(40)
      expect(described_class.mood(d)).to eq(:sad)
    end

    it '空腹の犬はおねだりになること' do
      d = dog
      d.get_hungrier(60)
      expect(described_class.mood(d)).to eq(:hungry)
    end

    it '愛着が安定し運動も足りた犬はごきげんになること' do
      d = dog
      2.times { d.reassure } # 信頼70で安定した愛着
      d.exercise(60)         # 必要量を満たす
      expect(described_class.mood(d)).to eq(:happy)
    end

    it 'とくに問題のない犬はふつうになること' do
      expect(described_class.mood(dog)).to eq(:content)
    end
  end

  describe '.for' do
    it '気分に対応した顔の文字列を返すこと' do
      expect(described_class.for(dog)).to include('ふつう')
    end
  end
end
