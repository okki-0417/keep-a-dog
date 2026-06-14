# frozen_string_literal: true

module Kennel
  module Infrastructure
    module Persistence
      class SqliteDogRepository
        include Domain::Repositories::DogRepository

        COLUMNS = %w[
          id breed sex neutered neutered_at_age age_in_days weight_in_grams hunger socialization trust arousal valence
          pain fearfulness exercise_minutes_today hydration acute_bloat_risk
          tartar separation_distress absence_tolerance_hours death_cause
        ].freeze
        SAVEPOINT = 'save_dog'

        def initialize(db)
          @db = db
        end

        # 集約は整合性の境界なので、1頭の保存は savepoint で必ずアトミックにする。
        def save(dog)
          snapshot = dog.to_snapshot
          atomically do
            upsert_dog(snapshot)
            replace_training(snapshot)
            replace_conditions(snapshot)
            replace_vaccinations(snapshot)
          end
          dog
        end

        def find(id)
          row = @db.get_first_row('SELECT * FROM dogs WHERE id = ?', [id])
          row && Domain::Dog.from_snapshot(snapshot_from(row))
        end

        def delete(id)
          @db.execute('DELETE FROM dogs WHERE id = ?', [id])
        end

        def all
          @db.execute('SELECT id FROM dogs').map { |row| find(row['id']) }
        end

        private

        def atomically
          @db.execute("SAVEPOINT #{SAVEPOINT}")
          yield
          @db.execute("RELEASE SAVEPOINT #{SAVEPOINT}")
        rescue StandardError
          @db.execute("ROLLBACK TO SAVEPOINT #{SAVEPOINT}")
          @db.execute("RELEASE SAVEPOINT #{SAVEPOINT}")
          raise
        end

        def upsert_dog(snapshot)
          assignments = COLUMNS.drop(1).map { |column| "#{column}=excluded.#{column}" }.join(', ')
          placeholders = (['?'] * COLUMNS.size).join(', ')
          @db.execute(
            "INSERT INTO dogs (#{COLUMNS.join(', ')}) VALUES (#{placeholders}) " \
            "ON CONFLICT(id) DO UPDATE SET #{assignments}",
            [
              snapshot.id, snapshot.breed_key.to_s, snapshot.sex.to_s, (snapshot.neutered ? 1 : 0),
              snapshot.neutered_at_age, snapshot.age_in_days, snapshot.weight_in_grams,
              snapshot.hunger, snapshot.socialization, snapshot.trust, snapshot.arousal, snapshot.valence,
              snapshot.pain, snapshot.fearfulness, snapshot.exercise_minutes_today, snapshot.hydration,
              (snapshot.acute_bloat_risk ? 1 : 0),
              snapshot.tartar, snapshot.separation_distress, snapshot.absence_tolerance_hours,
              snapshot.death_cause&.to_s
            ]
          )
        end

        def replace_training(snapshot)
          @db.execute('DELETE FROM dog_training WHERE dog_id = ?', [snapshot.id])
          snapshot.training.each do |(cue, context), points|
            @db.execute(
              'INSERT INTO dog_training (dog_id, cue, context, points) VALUES (?, ?, ?, ?)',
              [snapshot.id, cue.to_s, context.to_s, points]
            )
          end
        end

        def replace_conditions(snapshot)
          @db.execute('DELETE FROM dog_conditions WHERE dog_id = ?', [snapshot.id])
          snapshot.conditions.each do |condition_key|
            @db.execute('INSERT INTO dog_conditions (dog_id, condition) VALUES (?, ?)', [snapshot.id, condition_key.to_s])
          end
        end

        def replace_vaccinations(snapshot)
          @db.execute('DELETE FROM dog_vaccinations WHERE dog_id = ?', [snapshot.id])
          snapshot.vaccinations.each do |disease, doses|
            @db.execute('INSERT INTO dog_vaccinations (dog_id, disease, doses) VALUES (?, ?, ?)', [snapshot.id, disease.to_s, doses])
          end
        end

        def snapshot_from(row)
          Domain::Dog::Snapshot.new(
            id: row['id'], breed_key: row['breed'].to_sym, sex: row['sex'].to_sym,
            neutered: row['neutered'] == 1, neutered_at_age: row['neutered_at_age'], age_in_days: row['age_in_days'],
            weight_in_grams: row['weight_in_grams'], hunger: row['hunger'], socialization: row['socialization'],
            trust: row['trust'], arousal: row['arousal'], valence: row['valence'], pain: row['pain'],
            fearfulness: row['fearfulness'], exercise_minutes_today: row['exercise_minutes_today'],
            hydration: row['hydration'], acute_bloat_risk: row['acute_bloat_risk'] == 1,
            tartar: row['tartar'], separation_distress: row['separation_distress'],
            absence_tolerance_hours: row['absence_tolerance_hours'], death_cause: row['death_cause']&.to_sym,
            training: load_training(row['id']), conditions: load_conditions(row['id']),
            vaccinations: load_vaccinations(row['id'])
          )
        end

        def load_vaccinations(dog_id)
          @db.execute('SELECT disease, doses FROM dog_vaccinations WHERE dog_id = ?', [dog_id])
             .to_h { |r| [r['disease'].to_sym, r['doses']] }
        end

        def load_training(dog_id)
          @db.execute('SELECT cue, context, points FROM dog_training WHERE dog_id = ?', [dog_id])
             .to_h { |r| [[r['cue'].to_sym, r['context'].to_sym], r['points']] }
        end

        def load_conditions(dog_id)
          @db.execute('SELECT condition FROM dog_conditions WHERE dog_id = ? ORDER BY condition', [dog_id])
             .map { |r| r['condition'].to_sym }
        end
      end
    end
  end
end
