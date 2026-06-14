# frozen_string_literal: true

require 'sqlite3'

module Kennel
  module Infrastructure
    module Persistence
      module Sqlite
        module_function

        def connect(path = ':memory:')
          db = SQLite3::Database.new(path)
          db.results_as_hash = true
          db.execute('PRAGMA foreign_keys = ON')
          db.execute_batch(<<~SQL)
            CREATE TABLE IF NOT EXISTS dogs (
              id                      TEXT PRIMARY KEY,
              breed                   TEXT    NOT NULL,
              sex                     TEXT    NOT NULL,
              neutered                INTEGER NOT NULL,
              neutered_at_age         INTEGER,
              age_in_days             INTEGER NOT NULL,
              weight_in_grams         INTEGER NOT NULL,
              hunger                  INTEGER NOT NULL,
              socialization           INTEGER NOT NULL,
              trust                   INTEGER NOT NULL,
              arousal                 INTEGER NOT NULL,
              valence                 INTEGER NOT NULL,
              pain                    INTEGER NOT NULL,
              fearfulness             INTEGER NOT NULL,
              exercise_minutes_today  INTEGER NOT NULL,
              hydration               INTEGER NOT NULL,
              acute_bloat_risk        INTEGER NOT NULL,
              tartar                  INTEGER NOT NULL,
              separation_distress     INTEGER NOT NULL,
              absence_tolerance_hours INTEGER NOT NULL,
              death_cause             TEXT
            );

            CREATE TABLE IF NOT EXISTS dog_vaccinations (
              dog_id  TEXT    NOT NULL REFERENCES dogs(id) ON DELETE CASCADE,
              disease TEXT    NOT NULL,
              doses   INTEGER NOT NULL,
              PRIMARY KEY (dog_id, disease)
            );

            CREATE TABLE IF NOT EXISTS dog_training (
              dog_id  TEXT    NOT NULL REFERENCES dogs(id) ON DELETE CASCADE,
              cue     TEXT    NOT NULL,
              context TEXT    NOT NULL,
              points  INTEGER NOT NULL,
              PRIMARY KEY (dog_id, cue, context)
            );

            CREATE TABLE IF NOT EXISTS dog_conditions (
              dog_id    TEXT NOT NULL REFERENCES dogs(id) ON DELETE CASCADE,
              condition TEXT NOT NULL,
              PRIMARY KEY (dog_id, condition)
            );
          SQL
          db
        end
      end
    end
  end
end
