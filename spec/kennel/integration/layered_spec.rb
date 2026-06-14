# frozen_string_literal: true

RSpec.describe 'レイヤード統合(SQLite構成)' do
  let(:container) { Kennel::Composition::Container.sqlite }
  let(:commands) { Kennel::Application::Commands }

  it '迎える→しつけ→1日経過 が同じユースケースでSQLite永続化されること' do
    dog = container.adopt_dog.call(commands::AdoptDogCommand.new(breed_key: :shiba, age_in_days: 400))
    container.train_dog.call(commands::TrainDogCommand.new(dog_id: dog.id, cue: :sit, context: :kitchen))
    container.live_a_day.call(commands::LiveADayCommand.new(dog_id: dog.id, intake_kcal: 0))

    saved = container.dogs.find(dog.id)
    expect([saved.age_in_days, saved.breed.name]).to eq([401, '柴犬'])
  end
end
