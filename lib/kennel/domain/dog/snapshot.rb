# frozen_string_literal: true

module Kennel
  module Domain
    class Dog
      Snapshot = Data.define(
        :id, :breed_key, :sex, :age_in_days, :weight_in_grams, :hunger,
        :socialization, :trust, :arousal, :valence, :death_cause,
        :neutered, :neutered_at_age, :pain, :fearfulness, :exercise_minutes_today, :hydration,
        :acute_bloat_risk, :tartar, :separation_distress, :absence_tolerance_hours,
        :training, :conditions, :vaccinations
      )
    end
  end
end
