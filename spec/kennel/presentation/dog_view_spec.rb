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
end
