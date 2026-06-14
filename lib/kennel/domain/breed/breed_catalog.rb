# frozen_string_literal: true

module Kennel
  module Domain
    module Breed
      module BreedCatalog
        # 体格が大きい犬種ほど性成熟は遅く、骨格成熟(成長板の閉鎖)はさらに遅れ、寿命は短い。
        DEFINITIONS = {
          chihuahua: {
            name: 'チワワ', coat: :short, trainability: 20, daily_exercise_minutes: 30,
            maturity_age_days: 300, skeletal_maturity_age_days: 330,
            social_maturity_age_days: 540, lifespan_days: 5_840, ideal_weight_grams: 2_500,
            predispositions: %i[patellar_luxation dental_disease]
          },
          french_bulldog: {
            name: 'フレンチブルドッグ', coat: :short, brachycephalic: true, trainability: 18, daily_exercise_minutes: 30,
            maturity_age_days: 300, skeletal_maturity_age_days: 365,
            social_maturity_age_days: 600, lifespan_days: 4_015, ideal_weight_grams: 11_000,
            predispositions: %i[atopy]
          },
          shiba: {
            name: '柴犬', coat: :double, trainability: 12, daily_exercise_minutes: 60,
            maturity_age_days: 365, skeletal_maturity_age_days: 450,
            social_maturity_age_days: 730, lifespan_days: 5_475, ideal_weight_grams: 9_000,
            predispositions: %i[atopy]
          },
          saint_bernard: {
            name: 'セントバーナード', coat: :long, deep_chested: true, trainability: 16, daily_exercise_minutes: 45,
            maturity_age_days: 600, skeletal_maturity_age_days: 730,
            social_maturity_age_days: 1_095, lifespan_days: 3_285, ideal_weight_grams: 70_000,
            predispositions: %i[hip_dysplasia]
          }
        }.freeze

        module_function

        def fetch(key)
          attributes = DEFINITIONS.fetch(key) { raise ArgumentError, "未知の犬種です: #{key.inspect}" }
          Breed.new(key: key, **attributes)
        end
      end
    end
  end
end
