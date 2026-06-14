# frozen_string_literal: true

require 'securerandom'

module Kennel
  module Domain
    class Dog
      # 体組織のエネルギー密度(約7700kcal/kg)。収支の余剰・不足を体重変化に換算する。
      KCAL_PER_GRAM = 7.7
      MIN_WEIGHT_GRAMS = 1
      HUNGRY_THRESHOLD = 50
      MAX_HUNGER = 100
      FLUENCY_THRESHOLD = 100
      GENERALIZATION_MIN_CONTEXTS = 3
      SOCIALIZATION_WINDOW_DAYS = (21..98)
      IN_WINDOW_SOCIALIZATION_GAIN = 20
      AFTER_WINDOW_SOCIALIZATION_GAIN = 3
      WELL_SOCIALIZED_THRESHOLD = 70
      FEAR_PERIODS_DAYS = [(56..77), (180..420)].freeze
      FEAR_PERIOD_IMPRINT = 40
      NORMAL_FRIGHT = 10
      FEARFUL_THRESHOLD = 30
      INITIAL_TRUST = 50
      SECURE_ATTACHMENT_THRESHOLD = 70
      REASSURE_TRUST_GAIN = 10
      PUNISH_TRUST_LOSS = 20
      THREAT_TRUST_LOSS = 15
      AROUSED_THRESHOLD = 60
      DECIDUOUS_TEETH = 28
      PERMANENT_TEETH = 42
      TEETHING_WINDOW_DAYS = (84..210)
      PERMANENT_TEETH_BY_DAYS = 210
      PERIODONTAL_RISK_THRESHOLD = 70
      MATERNAL_ANTIBODY_DAYS = 112
      VACCINE_SERIES_DOSES = 3
      INITIAL_ABSENCE_TOLERANCE_HOURS = 2
      DESENSITIZE_TOLERANCE_GAIN = 2
      DISTRESS_PER_EXCESS_HOUR = 10
      PUNISH_DISTRESS_GAIN = 20
      SEPARATION_ANXIETY_THRESHOLD = 50
      NEUTERED_ENERGY_FACTOR = 0.75
      GROWTH_PLATE_DELAY_DAYS = 90
      OBVIOUS_PAIN_THRESHOLD = 70
      WATER_ML_PER_KG = 55
      DEHYDRATION_THRESHOLD = 70

      attr_reader :id, :breed, :sex, :weight_in_grams, :hunger, :socialization, :trust, :separation_distress

      def initialize(breed:, age_in_days: 0, weight_in_grams: nil, sex: :male, id: SecureRandom.uuid)
        @id = id
        @breed = breed
        @sex = sex
        @neutered = false
        @neutered_at_age = nil
        @age = AgeInDays.new(age_in_days)
        @weight_in_grams = weight_in_grams || breed.ideal_weight_grams
        @hunger = 0
        @training = Hash.new(0)
        @socialization = 0
        @fearfulness = 0
        @trust = INITIAL_TRUST
        @arousal = 0
        @valence = 0
        @conditions = []
        @acute_bloat_risk = false
        @pain = 0
        @exercise_minutes_today = 0
        @hydration = 100
        @tartar = 0
        @vaccinations = Hash.new(0)
        @separation_distress = 0
        @absence_tolerance_hours = INITIAL_ABSENCE_TOLERANCE_HOURS
        @death = nil
      end

      # 永続化のために集約の状態を素の値の塊として書き出す(メメント)。
      def to_snapshot
        Snapshot.new(
          id: @id, breed_key: @breed.key, sex: @sex, age_in_days: @age.days, weight_in_grams: @weight_in_grams,
          hunger: @hunger, socialization: @socialization, trust: @trust, arousal: @arousal, valence: @valence,
          death_cause: @death&.cause, neutered: @neutered, neutered_at_age: @neutered_at_age, pain: @pain,
          fearfulness: @fearfulness, exercise_minutes_today: @exercise_minutes_today, hydration: @hydration,
          acute_bloat_risk: @acute_bloat_risk, tartar: @tartar, separation_distress: @separation_distress,
          absence_tolerance_hours: @absence_tolerance_hours,
          training: @training.dup, conditions: @conditions.map(&:key), vaccinations: @vaccinations.dup
        )
      end

      # スナップショットから集約を復元する(new を通さず、すでに妥当な状態として組み立てる)。
      def self.from_snapshot(snapshot)
        dog = allocate
        dog.send(:load_snapshot, snapshot)
        dog
      end

      def life_stage
        LifeStage.of(age: @age, breed: @breed)
      end

      def sexually_mature?
        @age.days >= @breed.maturity_age_days
      end

      def skeletally_mature?
        @age.days >= effective_skeletal_maturity_days
      end

      def intact?
        !@neutered
      end

      def neutered?
        @neutered
      end

      def neuter
        @neutered = true
        @neutered_at_age = @age.days
        self
      end

      def at_risk_of_pyometra?
        @sex == :female && intact?
      end

      def at_risk_of_mammary_tumors?
        @sex == :female && intact?
      end

      def at_risk_of_prostate_problems?
        @sex == :male && intact?
      end

      def experience_pain(amount)
        @pain = [@pain + amount, 100].min
        self
      end

      def in_pain?
        @pain.positive?
      end

      # 犬は痛みを隠すため、強くなって初めてはっきりした様子が現れる。
      def obviously_in_pain?
        @pain >= OBVIOUS_PAIN_THRESHOLD
      end

      def masking_pain?
        in_pain? && !obviously_in_pain?
      end

      def daily_exercise_need_minutes
        @breed.daily_exercise_minutes
      end

      def exercise(minutes)
        @exercise_minutes_today += minutes
        self
      end

      def well_exercised?
        @exercise_minutes_today >= daily_exercise_need_minutes
      end

      def under_exercised?
        !well_exercised?
      end

      # 運動不足はあり余ったエネルギーで問題行動につながる("a tired dog is a good dog")。
      def at_risk_of_problem_behavior?
        under_exercised?
      end

      def daily_water_need_ml
        (@weight_in_grams / 1000.0 * WATER_ML_PER_KG).round
      end

      def lose_water(amount)
        @hydration = [@hydration - amount, 0].max
        self
      end

      def give_water
        @hydration = 100
        self
      end

      def dehydrated?
        @hydration <= DEHYDRATION_THRESHOLD
      end

      def socially_mature?
        @age.days >= @breed.social_maturity_age_days
      end

      def safe_for_high_impact_exercise?
        skeletally_mature?
      end

      # 犬の年齢の人間換算は単純な×7ではなく対数的(Wang et al. 2019, エピジェネティック時計)。
      def human_equivalent_age
        years = [@age.days / 365.0, 0.1].max
        ((16 * Math.log(years)) + 31).round
      end

      def pass_day(days = 1)
        return self if dead?

        @age = @age.advanced_by(days)
        @death = Death.new(cause: :old_age) if @age.days >= @breed.lifespan_days
        self
      end

      def resting_energy_requirement
        kg = @weight_in_grams / 1000.0
        (70 * (kg**0.75)).round
      end

      def maintenance_energy_requirement
        factor = life_stage.energy_factor * (@neutered ? NEUTERED_ENERGY_FACTOR : 1.0)
        (resting_energy_requirement * factor).round
      end

      def body_condition_score
        ratio = @weight_in_grams.to_f / @breed.ideal_weight_grams
        (5 + ((ratio - 1.0) / 0.10).round).clamp(1, 9)
      end

      def underweight?
        body_condition_score <= 3
      end

      def ideal_weight?
        (4..5).cover?(body_condition_score)
      end

      def overweight?
        (6..7).cover?(body_condition_score)
      end

      def obese?
        body_condition_score >= 8
      end

      def metabolize(intake_kcal)
        surplus = intake_kcal - maintenance_energy_requirement
        @weight_in_grams = [@weight_in_grams + (surplus / KCAL_PER_GRAM).round, MIN_WEIGHT_GRAMS].max
        self
      end

      def get_hungrier(amount)
        @hunger = [@hunger + amount, MAX_HUNGER].min
        self
      end

      def eat(satiety)
        @hunger = [@hunger - satiety, 0].max
        self
      end

      def hungry?
        @hunger >= HUNGRY_THRESHOLD
      end

      def recommended_meals_per_day
        life_stage.recommended_meals_per_day
      end

      def prone_to_bloat?
        @breed.deep_chested?
      end

      def bolt_large_meal
        @acute_bloat_risk = true if prone_to_bloat?
        self
      end

      def exercise_soon_after_eating
        @acute_bloat_risk = true if prone_to_bloat?
        self
      end

      def at_acute_bloat_risk?
        @acute_bloat_risk
      end

      def heat_tolerance_celsius
        @breed.heat_tolerance_celsius
      end

      def cold_tolerance_celsius
        @breed.cold_tolerance_celsius
      end

      def at_risk_of_heatstroke?(ambient_celsius)
        ambient_celsius > heat_tolerance_celsius
      end

      def train(cue, context)
        @training[[cue, context]] += @breed.trainability
        self
      end

      def fluent?(cue, context)
        @training[[cue, context]] >= FLUENCY_THRESHOLD
      end

      def generalized?(cue)
        mastered_contexts(cue).size >= GENERALIZATION_MIN_CONTEXTS
      end

      def responds_to?(cue, context)
        fluent?(cue, context) || generalized?(cue)
      end

      def in_socialization_window?
        SOCIALIZATION_WINDOW_DAYS.cover?(@age.days)
      end

      def socialize
        gain = in_socialization_window? ? IN_WINDOW_SOCIALIZATION_GAIN : AFTER_WINDOW_SOCIALIZATION_GAIN
        @socialization = [@socialization + gain, 100].min
        self
      end

      def well_socialized?
        @socialization >= WELL_SOCIALIZED_THRESHOLD
      end

      def in_fear_period?
        FEAR_PERIODS_DAYS.any? { |period| period.cover?(@age.days) }
      end

      def scary_experience
        @fearfulness = [@fearfulness + (in_fear_period? ? FEAR_PERIOD_IMPRINT : NORMAL_FRIGHT), 100].min
        self
      end

      def fearful?
        @fearfulness >= FEARFUL_THRESHOLD
      end

      def reassure
        @trust = [@trust + REASSURE_TRUST_GAIN, 100].min
        self
      end

      def punish
        @trust = [@trust - PUNISH_TRUST_LOSS, 0].max
        @separation_distress = [@separation_distress + PUNISH_DISTRESS_GAIN, 100].min
        self
      end

      def left_alone(hours)
        excess = hours - @absence_tolerance_hours
        @separation_distress = [@separation_distress + (excess * DISTRESS_PER_EXCESS_HOUR), 100].min if excess.positive?
        self
      end

      def desensitize_to_absence
        @absence_tolerance_hours += DESENSITIZE_TOLERANCE_GAIN
        self
      end

      def separation_anxiety?
        @separation_distress >= SEPARATION_ANXIETY_THRESHOLD
      end

      def expose_to_threat
        @trust = [@trust - THREAT_TRUST_LOSS, 0].max
        self
      end

      def securely_attached?
        @trust >= SECURE_ATTACHMENT_THRESHOLD
      end

      def react_to(arousal:, valence:)
        @arousal = arousal
        @valence = valence
        self
      end

      def aroused?
        @arousal >= AROUSED_THRESHOLD
      end

      def pleased?
        @valence.positive?
      end

      def fall_ill(condition)
        @conditions << condition unless suffers_from?(condition.key)
        self
      end

      # 治療は急性の病気を治し、慢性の病気は管理にとどめる(完治させない)。
      def treat
        @conditions = @conditions.select(&:chronic?)
        self
      end

      def sick?
        !@conditions.empty?
      end

      def suffers_from?(condition_key)
        @conditions.any? { |condition| condition.key == condition_key }
      end

      def current_conditions
        @conditions.map(&:key)
      end

      def predisposed_to?(condition_key)
        @breed.predisposed_to?(condition_key)
      end

      def tooth_count
        @age.days < PERMANENT_TEETH_BY_DAYS ? DECIDUOUS_TEETH : PERMANENT_TEETH
      end

      def teething?
        TEETHING_WINDOW_DAYS.cover?(@age.days)
      end

      def neglect_dental_care(amount)
        @tartar = [@tartar + amount, 100].min
        self
      end

      def brush_teeth
        @tartar = 0
        self
      end

      def at_risk_of_periodontal_disease?
        @tartar >= PERIODONTAL_RISK_THRESHOLD
      end

      def sheds_seasonally?
        @breed.sheds_seasonally?
      end

      def should_not_be_shaved?
        @breed.should_not_be_shaved?
      end

      def coat_prone_to_matting?
        @breed.coat_prone_to_matting?
      end

      def daily_sleep_hours_needed
        life_stage.daily_sleep_hours_needed
      end

      def vaccinate(disease)
        @vaccinations[disease] += 1
        self
      end

      # 移行抗体が残る幼い子犬は連続接種(シリーズ)が要り、消えた後は単回で免疫がつく。
      def immune_to?(disease)
        required_doses = @age.days < MATERNAL_ANTIBODY_DAYS ? VACCINE_SERIES_DOSES : 1
        @vaccinations[disease] >= required_doses
      end

      def age_in_days
        @age.days
      end

      def alive?
        @death.nil?
      end

      def dead?
        !alive?
      end

      def death
        @death
      end

      private

      # 骨格成熟より前に去勢・避妊すると、成長板の閉鎖が遅れる。
      def effective_skeletal_maturity_days
        base = @breed.skeletal_maturity_age_days
        early_neuter = @neutered && @neutered_at_age < base
        early_neuter ? base + GROWTH_PLATE_DELAY_DAYS : base
      end

      def load_snapshot(snapshot)
        @id = snapshot.id
        @breed = Breed::BreedCatalog.fetch(snapshot.breed_key)
        @sex = snapshot.sex
        @neutered = snapshot.neutered
        @neutered_at_age = snapshot.neutered_at_age
        @pain = snapshot.pain
        @fearfulness = snapshot.fearfulness
        @exercise_minutes_today = snapshot.exercise_minutes_today
        @hydration = snapshot.hydration
        @acute_bloat_risk = snapshot.acute_bloat_risk
        @age = AgeInDays.new(snapshot.age_in_days)
        @weight_in_grams = snapshot.weight_in_grams
        @hunger = snapshot.hunger
        @socialization = snapshot.socialization
        @trust = snapshot.trust
        @arousal = snapshot.arousal
        @valence = snapshot.valence
        @death = snapshot.death_cause && Death.new(cause: snapshot.death_cause)
        @tartar = snapshot.tartar
        @separation_distress = snapshot.separation_distress
        @absence_tolerance_hours = snapshot.absence_tolerance_hours
        @training = Hash.new(0).merge(snapshot.training)
        @conditions = snapshot.conditions.map { |key| Medical::ConditionCatalog.fetch(key) }
        @vaccinations = Hash.new(0).merge(snapshot.vaccinations)
      end

      def mastered_contexts(cue)
        @training.select { |key, points| key.first == cue && points >= FLUENCY_THRESHOLD }.keys.map(&:last)
      end
    end
  end
end
