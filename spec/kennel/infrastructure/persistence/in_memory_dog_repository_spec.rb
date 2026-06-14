# frozen_string_literal: true

RSpec.describe Kennel::Infrastructure::Persistence::InMemoryDogRepository do
  subject(:repository) { described_class.new }

  def build_dog
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: 400)
  end

  describe '#save / #find' do
    it '保存した犬を id で取得できること' do
      dog = build_dog
      repository.save(dog)
      expect(repository.find(dog.id)).to be(dog)
    end

    it '存在しない id では nil を返すこと' do
      expect(repository.find('missing')).to be_nil
    end
  end

  describe '#delete' do
    it '削除すると取得できなくなること' do
      dog = build_dog
      repository.save(dog)
      repository.delete(dog.id)
      expect(repository.find(dog.id)).to be_nil
    end
  end
end
