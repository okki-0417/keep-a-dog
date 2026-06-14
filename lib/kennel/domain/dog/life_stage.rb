# frozen_string_literal: true

module Kennel
  module Domain
    class Dog
      class LifeStage
        LABELS = { puppy: '子犬', adolescent: '青年', adult: '成犬', senior: '老犬' }.freeze
        ENERGY_FACTORS = { puppy: 3.0, adolescent: 2.0, adult: 1.6, senior: 1.4 }.freeze
        MEALS_PER_DAY = { puppy: 4, adolescent: 3, adult: 2, senior: 2 }.freeze
        SLEEP_HOURS = { puppy: 19, adolescent: 14, adult: 13, senior: 18 }.freeze

        def self.of(age:, breed:)
          days = age.days
          key = if days >= breed.senior_age_days
                  :senior
                elsif days >= breed.maturity_age_days
                  :adult
                elsif days >= (breed.maturity_age_days / 2)
                  :adolescent
                else
                  :puppy
                end
          new(key)
        end

        attr_reader :key

        def initialize(key)
          @key = key
        end

        def label
          LABELS.fetch(@key)
        end

        def energy_factor
          ENERGY_FACTORS.fetch(@key)
        end

        def recommended_meals_per_day
          MEALS_PER_DAY.fetch(@key)
        end

        def daily_sleep_hours_needed
          SLEEP_HOURS.fetch(@key)
        end

        def puppy?
          @key == :puppy
        end

        def adult?
          @key == :adult
        end

        def senior?
          @key == :senior
        end
      end
    end
  end
end
