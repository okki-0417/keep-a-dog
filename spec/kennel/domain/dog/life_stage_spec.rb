# frozen_string_literal: true

RSpec.describe Kennel::Domain::Dog::LifeStage do
  describe '.of' do
    def stage_at(days)
      described_class.of(
        age: Kennel::Domain::Dog::AgeInDays.new(days),
        breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba)
      ).key
    end

    it '日齢に応じて子犬/青年/成犬/老犬を導くこと' do
      expect([stage_at(90), stage_at(200), stage_at(400), stage_at(4_500)])
        .to eq(%i[puppy adolescent adult senior])
    end
  end

  describe '#label' do
    it 'ステージの和名を返すこと(:senior→老犬)' do
      expect(described_class.new(:senior).label).to eq('老犬')
    end
  end

  describe '#energy_factor' do
    it '各ステージの維持係数を返すこと(子犬3.0/青年2.0/成犬1.6/老犬1.4)' do
      factors = %i[puppy adolescent adult senior].map { |key| described_class.new(key).energy_factor }
      expect(factors).to eq([3.0, 2.0, 1.6, 1.4])
    end
  end

  describe '#recommended_meals_per_day' do
    it '各ステージの推奨食事回数を返すこと(子犬4/青年3/成犬2/老犬2)' do
      meals = %i[puppy adolescent adult senior].map { |key| described_class.new(key).recommended_meals_per_day }
      expect(meals).to eq([4, 3, 2, 2])
    end
  end

  describe '述語' do
    it 'キーに応じて puppy? / adult? / senior? が真を返すこと' do
      flags = [described_class.new(:puppy).puppy?, described_class.new(:adult).adult?, described_class.new(:senior).senior?]
      expect(flags).to eq([true, true, true])
    end
  end

  describe '#daily_sleep_hours_needed' do
    it '子犬・老犬は成犬より多く、各ステージの値を返すこと(子犬19/青年14/成犬13/老犬18)' do
      hours = %i[puppy adolescent adult senior].map { |key| described_class.new(key).daily_sleep_hours_needed }
      expect(hours).to eq([19, 14, 13, 18])
    end
  end
end
