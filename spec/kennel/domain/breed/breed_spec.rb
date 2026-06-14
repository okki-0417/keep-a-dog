# frozen_string_literal: true

RSpec.describe Kennel::Domain::Breed::Breed do
  let(:shiba) { Kennel::Domain::Breed::BreedCatalog.fetch(:shiba) }

  describe '#senior_age_days' do
    it '寿命の75%を四捨五入して返すこと(柴犬5475→4106)' do
      expect(shiba.senior_age_days).to eq(4_106)
    end
  end

  describe '#heat_tolerance_celsius / #cold_tolerance_celsius' do
    it '被毛・体格・短頭から快適気温の上下限を導くこと(柴犬は上限26℃・下限-3℃)' do
      expect([shiba.heat_tolerance_celsius, shiba.cold_tolerance_celsius]).to eq([26, -3])
    end
  end

  describe '#predisposed_to?' do
    it '素因リストに含む病気だけ true を返すこと' do
      expect([shiba.predisposed_to?(:atopy), shiba.predisposed_to?(:hip_dysplasia)]).to eq([true, false])
    end
  end

  describe '体質フラグ' do
    it 'deep_chested? / brachycephalic? を犬種に応じて返すこと' do
      saint_bernard = Kennel::Domain::Breed::BreedCatalog.fetch(:saint_bernard)
      french_bulldog = Kennel::Domain::Breed::BreedCatalog.fetch(:french_bulldog)
      expect([saint_bernard.deep_chested?, french_bulldog.brachycephalic?, shiba.deep_chested?])
        .to eq([true, true, false])
    end
  end

  describe '被毛の手入れ' do
    it 'ダブルコートは換毛し刈れない、長毛は毛玉、短毛はいずれも該当しないこと' do
      long_coat = Kennel::Domain::Breed::BreedCatalog.fetch(:saint_bernard)
      short_coat = Kennel::Domain::Breed::BreedCatalog.fetch(:chihuahua)
      expect([shiba.sheds_seasonally?, shiba.should_not_be_shaved?, long_coat.coat_prone_to_matting?,
              short_coat.sheds_seasonally?, short_coat.coat_prone_to_matting?])
        .to eq([true, true, true, false, false])
    end
  end

  describe '#daily_exercise_minutes' do
    it '犬種ごとの一日の必要運動量を返すこと' do
      expect(shiba.daily_exercise_minutes).to be > Kennel::Domain::Breed::BreedCatalog.fetch(:chihuahua).daily_exercise_minutes
    end
  end
end
