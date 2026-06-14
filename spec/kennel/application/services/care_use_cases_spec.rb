# frozen_string_literal: true

RSpec.describe 'アプリ層: 世話のユースケース' do
  let(:container) { Kennel::Composition::Container.new }
  let(:commands) { Kennel::Application::Commands }
  let(:catalog) { Kennel::Domain::Breed::BreedCatalog }

  def adopt(breed_key: :shiba, age_in_days: 400)
    container.adopt_dog.call(commands::AdoptDogCommand.new(breed_key: breed_key, age_in_days: age_in_days))
  end

  describe Kennel::Application::Services::FeedDog do
    it 'ごはんで空腹が満たされること' do
      dog = adopt
      container.live_a_day.call(commands::LiveADayCommand.new(dog_id: dog.id, intake_kcal: 0)) # 空腹40
      container.feed_dog.call(commands::FeedDogCommand.new(dog_id: dog.id, satiety: 40, gulped: false))
      expect(container.dogs.find(dog.id).hunger).to eq(0)
    end

    it '深胸の犬種が一気食いすると胃捻転の急性リスクになること' do
      dog = adopt(breed_key: :saint_bernard)
      container.feed_dog.call(commands::FeedDogCommand.new(dog_id: dog.id, satiety: 40, gulped: true))
      expect(container.dogs.find(dog.id).at_acute_bloat_risk?).to be(true)
    end
  end

  describe Kennel::Application::Services::GiveWater do
    it '水をあげると脱水が解消されること' do
      dog = adopt
      2.times { container.live_a_day.call(commands::LiveADayCommand.new(dog_id: dog.id, intake_kcal: 0)) } # 水分40
      container.give_water.call(commands::GiveWaterCommand.new(dog_id: dog.id))
      expect(container.dogs.find(dog.id).dehydrated?).to be(false)
    end
  end

  describe Kennel::Application::Services::WalkDog do
    it '必要時間ぶん散歩すると運動が足りること' do
      dog = adopt
      container.walk_dog.call(commands::WalkDogCommand.new(dog_id: dog.id, minutes: 60))
      expect(container.dogs.find(dog.id).well_exercised?).to be(true)
    end
  end

  describe Kennel::Application::Services::SocializeDog do
    it '社会化期の子犬は体験で社会化が大きく伸びること' do
      dog = adopt(age_in_days: 60)
      container.socialize_dog.call(commands::SocializeDogCommand.new(dog_id: dog.id))
      expect(container.dogs.find(dog.id).socialization).to eq(20)
    end
  end

  describe Kennel::Application::Services::PraiseDog do
    it 'なでてほめると信頼が増すこと' do
      dog = adopt
      container.praise_dog.call(commands::PraiseDogCommand.new(dog_id: dog.id))
      expect(container.dogs.find(dog.id).trust).to eq(60)
    end
  end

  describe Kennel::Application::Services::BrushTeeth do
    it '歯みがきで歯石が落ち、歯周病リスクが下がること' do
      dog = Kennel::Domain::Dog.new(breed: catalog.fetch(:shiba), age_in_days: 400)
      dog.neglect_dental_care(80)
      container.dogs.save(dog)
      container.brush_teeth.call(commands::BrushTeethCommand.new(dog_id: dog.id))
      expect(container.dogs.find(dog.id).at_risk_of_periodontal_disease?).to be(false)
    end
  end

  describe Kennel::Application::Services::VaccinateDog do
    it '移行抗体が消えた成犬は1回の接種で免疫がつくこと' do
      dog = adopt
      container.vaccinate_dog.call(commands::VaccinateDogCommand.new(dog_id: dog.id, disease: :rabies))
      expect(container.dogs.find(dog.id).immune_to?(:rabies)).to be(true)
    end
  end

  describe Kennel::Application::Services::NeuterDog do
    it '去勢・避妊が記録されること' do
      dog = adopt
      container.neuter_dog.call(commands::NeuterDogCommand.new(dog_id: dog.id))
      expect(container.dogs.find(dog.id).neutered?).to be(true)
    end
  end
end
