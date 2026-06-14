# frozen_string_literal: true

RSpec.describe Kennel::Application::Services::TreatDog do
  let(:container) { Kennel::Composition::Container.new }
  let(:commands) { Kennel::Application::Commands }

  def adopt
    container.adopt_dog.call(commands::AdoptDogCommand.new(breed_key: :shiba, age_in_days: 400))
  end

  describe '#call' do
    it '急性の病気は治療で消え、永続化されること' do
      dog = adopt
      dog.fall_ill(Kennel::Domain::Medical::ConditionCatalog.fetch(:kennel_cough))
      container.treat_dog.call(commands::TreatDogCommand.new(dog_id: dog.id))
      expect(container.dogs.find(dog.id).sick?).to be(false)
    end

    it '存在しない犬を指定すると Application::Errors::DogNotFound になること' do
      expect { container.treat_dog.call(commands::TreatDogCommand.new(dog_id: 'missing')) }
        .to raise_error(Kennel::Application::Errors::DogNotFound)
    end
  end
end
