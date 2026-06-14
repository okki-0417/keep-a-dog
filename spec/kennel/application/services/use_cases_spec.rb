# frozen_string_literal: true

RSpec.describe 'アプリ層のユースケース' do
  let(:container) { Kennel::Composition::Container.new }
  let(:commands) { Kennel::Application::Commands }

  describe Kennel::Application::Services::AdoptDog do
    it '犬を迎えて永続化し、idで取得できること' do
      dog = container.adopt_dog.call(commands::AdoptDogCommand.new(breed_key: :shiba, age_in_days: 60))
      expect(container.dogs.find(dog.id).breed.name).to eq('柴犬')
    end
  end

  describe Kennel::Application::Services::TrainDog do
    let(:dog) { container.adopt_dog.call(commands::AdoptDogCommand.new(breed_key: :chihuahua, age_in_days: 400)) }

    it 'しつけ結果が永続化されること' do
      5.times { container.train_dog.call(commands::TrainDogCommand.new(dog_id: dog.id, cue: :sit, context: :kitchen)) }
      expect(container.dogs.find(dog.id).fluent?(:sit, :kitchen)).to be(true)
    end

    it '存在しない犬を指定すると Application::Errors::DogNotFound になること' do
      expect { container.train_dog.call(commands::TrainDogCommand.new(dog_id: 'missing', cue: :sit, context: :kitchen)) }
        .to raise_error(Kennel::Application::Errors::DogNotFound)
    end
  end

  describe Kennel::Application::Services::LiveADay do
    let(:dog) { container.adopt_dog.call(commands::AdoptDogCommand.new(breed_key: :shiba, age_in_days: 400)) }

    it '1日進めると加齢・空腹が反映されて永続化されること' do
      container.live_a_day.call(commands::LiveADayCommand.new(dog_id: dog.id, intake_kcal: 0))
      saved = container.dogs.find(dog.id)
      expect([saved.age_in_days, saved.hungry?]).to eq([401, false])
    end

    it '維持量を下回る食事しか与えないと体重が減ること' do
      before = dog.weight_in_grams
      container.live_a_day.call(commands::LiveADayCommand.new(dog_id: dog.id, intake_kcal: 0))
      expect(container.dogs.find(dog.id).weight_in_grams).to be < before
    end
  end
end
