# frozen_string_literal: true

module Kennel
  module Domain
    module Breed
      class Breed
        # 老齢期は寿命の最後の25%(AAHAライフステージの定義)。
        SENIOR_LIFESPAN_RATIO = 0.75

        # 体温調節: 快適な気温の上限(暑さ耐性)と下限(寒さ耐性)を、被毛・短頭・体格から導く。
        HEAT_TOLERANCE_BASE = 30
        COLD_TOLERANCE_BASE = 5
        BRACHYCEPHALIC_HEAT_PENALTY = 8
        COAT_TRAITS = {
          short:  { heat_penalty: 0, cold_bonus: 0 },
          long:   { heat_penalty: 2, cold_bonus: 4 },
          double: { heat_penalty: 4, cold_bonus: 8 }
        }.freeze

        attr_reader :key, :name, :maturity_age_days, :skeletal_maturity_age_days,
                    :social_maturity_age_days, :lifespan_days, :ideal_weight_grams, :coat, :trainability,
                    :daily_exercise_minutes

        def initialize(key:, name:, maturity_age_days:, skeletal_maturity_age_days:,
                       social_maturity_age_days:, lifespan_days:, ideal_weight_grams:, coat:, trainability:,
                       daily_exercise_minutes:, deep_chested: false, brachycephalic: false, predispositions: [])
          @key = key
          @name = name
          @maturity_age_days = maturity_age_days
          @skeletal_maturity_age_days = skeletal_maturity_age_days
          @social_maturity_age_days = social_maturity_age_days
          @lifespan_days = lifespan_days
          @ideal_weight_grams = ideal_weight_grams
          @coat = coat
          @trainability = trainability
          @daily_exercise_minutes = daily_exercise_minutes
          @deep_chested = deep_chested
          @brachycephalic = brachycephalic
          @predispositions = predispositions
        end

        def deep_chested?
          @deep_chested
        end

        def predisposed_to?(condition_key)
          @predispositions.include?(condition_key)
        end

        def brachycephalic?
          @brachycephalic
        end

        def senior_age_days
          (@lifespan_days * SENIOR_LIFESPAN_RATIO).round
        end

        def sheds_seasonally?
          @coat == :double
        end

        def should_not_be_shaved?
          @coat == :double
        end

        def coat_prone_to_matting?
          @coat == :long
        end

        def heat_tolerance_celsius
          brachy = @brachycephalic ? BRACHYCEPHALIC_HEAT_PENALTY : 0
          HEAT_TOLERANCE_BASE - COAT_TRAITS.fetch(@coat)[:heat_penalty] - brachy - size_factor
        end

        def cold_tolerance_celsius
          COLD_TOLERANCE_BASE - COAT_TRAITS.fetch(@coat)[:cold_bonus] - size_factor
        end

        private

        # 体格の目安(理想体重10kgごとに1段階)。大きいほど暑さに弱く、寒さに強い。
        def size_factor
          @ideal_weight_grams / 10_000
        end
      end
    end
  end
end
