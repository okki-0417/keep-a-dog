# frozen_string_literal: true

RSpec.describe Kennel::Domain::Dog do
  def dog(breed: :shiba, age_in_days: 400, **opts)
    described_class.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed), age_in_days: age_in_days, **opts)
  end

  describe '.new' do
    it '体重を指定しなければ犬種の理想体重で始まること(柴犬9000g)' do
      expect(dog.weight_in_grams).to eq(9_000)
    end

    it '空腹・信頼などの初期値を持つこと(空腹0・信頼50)' do
      expect([dog.hunger, dog.trust]).to eq([0, 50])
    end
  end

  describe '#get_hungrier / #eat' do
    it '空腹は最大100で頭打ちになること' do
      expect(dog.get_hungrier(999).hunger).to eq(100)
    end

    it '空腹は0より下がらないこと' do
      expect(dog.eat(999).hunger).to eq(0)
    end
  end

  describe '#metabolize' do
    it '極端な不足でも体重は最低1gより下がらないこと' do
      d = dog
      d.metabolize(-10_000_000)
      expect(d.weight_in_grams).to be >= 1
    end
  end

  describe '#body_condition_score' do
    it '極端な体重でも1〜9にクランプされること' do
      scores = [dog(weight_in_grams: 1).body_condition_score, dog(weight_in_grams: 10_000_000).body_condition_score]
      expect(scores).to eq([1, 9])
    end
  end

  describe '#socialize' do
    it '社会化は100で頭打ちになること' do
      d = dog(age_in_days: 50) # 社会化期
      20.times { d.socialize }
      expect(d.socialization).to eq(100)
    end
  end

  describe '#reassure / #punish' do
    it '信頼は最大100で頭打ち、最小0で下げ止まること' do
      trusting = dog
      20.times { trusting.reassure }
      wary = dog
      20.times { wary.punish }
      expect([trusting.trust, wary.trust]).to eq([100, 0])
    end
  end

  describe '#fall_ill' do
    it '同じ病気を二度発症しても重複して保持しないこと' do
      d = dog
      condition = Kennel::Domain::Medical::ConditionCatalog.fetch(:hip_dysplasia)
      d.fall_ill(condition)
      d.fall_ill(condition)
      expect(d.current_conditions).to eq([:hip_dysplasia])
    end
  end

  describe '#treat' do
    it '急性は消し、慢性は残すこと' do
      d = dog
      d.fall_ill(Kennel::Domain::Medical::ConditionCatalog.fetch(:kennel_cough))
      d.fall_ill(Kennel::Domain::Medical::ConditionCatalog.fetch(:hip_dysplasia))
      d.treat
      expect(d.current_conditions).to eq([:hip_dysplasia])
    end
  end

  describe '#neuter と生殖ステータス' do
    it '去勢・避妊すると neutered? が true・intact? が false になること' do
      d = dog.tap(&:neuter)
      expect([d.neutered?, d.intact?]).to eq([true, false])
    end

    it '未避妊メスは子宮蓄膿症・乳腺腫瘍リスクを持ち、避妊で消えること' do
      intact = dog(sex: :female)
      spayed = dog(sex: :female).tap(&:neuter)
      expect([intact.at_risk_of_pyometra?, intact.at_risk_of_mammary_tumors?, spayed.at_risk_of_pyometra?])
        .to eq([true, true, false])
    end

    it '前立腺リスクは未去勢オスだけが持つこと' do
      expect([dog(sex: :male).at_risk_of_prostate_problems?, dog(sex: :female).at_risk_of_prostate_problems?])
        .to eq([true, false])
    end

    it '骨格成熟後に去勢しても骨格成熟は遅れないこと' do
      expect(dog(age_in_days: 500).tap(&:neuter).skeletally_mature?).to be(true)
    end
  end

  describe '#experience_pain' do
    it '中等度は隠し、強いとはっきり現れること(最大100でクランプ)' do
      moderate = dog.tap { |d| d.experience_pain(40) }
      severe = dog.tap { |d| d.experience_pain(999) }
      expect([moderate.masking_pain?, moderate.obviously_in_pain?, severe.obviously_in_pain?])
        .to eq([true, false, true])
    end
  end

  describe '#lose_water / #give_water' do
    it '水分は0でクランプし脱水に、水を与えると回復すること' do
      d = dog.tap { |dog| dog.lose_water(999) }
      expect { d.give_water }.to(change { d.dehydrated? }.from(true).to(false))
    end
  end

  describe '#exercise' do
    it '必要量に満たないと問題行動リスク、満たすと解消されること' do
      under = dog.tap { |d| d.exercise(d.daily_exercise_need_minutes - 1) }
      enough = dog.tap { |d| d.exercise(d.daily_exercise_need_minutes) }
      expect([under.at_risk_of_problem_behavior?, enough.well_exercised?]).to eq([true, true])
    end
  end

  describe '#neglect_dental_care / #brush_teeth' do
    it '歯石は100でクランプし歯周病リスクに、磨くと0に戻ること' do
      d = dog.tap { |dog| dog.neglect_dental_care(999) }
      expect { d.brush_teeth }.to(change { d.at_risk_of_periodontal_disease? }.from(true).to(false))
    end

    it '生え替わり前は乳歯28本、後は永久歯42本であること' do
      expect([dog(age_in_days: 60).tooth_count, dog(age_in_days: 400).tooth_count, dog(age_in_days: 150).teething?])
        .to eq([28, 42, true])
    end
  end

  describe '#vaccinate / #immune_to?' do
    it '移行抗体の残る子犬は連続接種が要り、成犬は単回で免疫がつくこと' do
      puppy = dog(age_in_days: 56)
      3.times { puppy.vaccinate(:distemper) }
      adult = dog(age_in_days: 400).tap { |d| d.vaccinate(:distemper) }
      once = dog(age_in_days: 56).tap { |d| d.vaccinate(:distemper) }
      expect([puppy.immune_to?(:distemper), adult.immune_to?(:distemper), once.immune_to?(:distemper)])
        .to eq([true, true, false])
    end
  end

  describe '#left_alone / #desensitize_to_absence' do
    it '耐性内の留守番は平気、超えると分離不安、慣らすと再び平気になること' do
      ok = dog.tap { |d| d.left_alone(2) }
      anxious = dog.tap { |d| d.left_alone(8) }
      desensitized = dog.tap { |d| 4.times { d.desensitize_to_absence } }.tap { |d| d.left_alone(8) }
      expect([ok.separation_anxiety?, anxious.separation_anxiety?, desensitized.separation_anxiety?])
        .to eq([false, true, false])
    end
  end

  describe '#scary_experience' do
    it '恐怖期は強く刻まれ、恐怖期外では刻まれにくいこと' do
      in_period = dog(age_in_days: 63).tap(&:scary_experience)
      outside = dog(age_in_days: 500).tap(&:scary_experience)
      expect([in_period.fearful?, outside.fearful?]).to eq([true, false])
    end
  end

  describe '#bolt_large_meal' do
    it '素因のある犬だけ急性胃捻転リスクになること' do
      prone = dog(breed: :saint_bernard).tap(&:bolt_large_meal)
      not_prone = dog(breed: :chihuahua).tap(&:bolt_large_meal)
      expect([prone.at_acute_bloat_risk?, not_prone.at_acute_bloat_risk?]).to eq([true, false])
    end
  end

  describe '#train / #responds_to?' do
    it '同じ文脈で習熟するとその文脈では応じるが、未習の文脈では応じないこと' do
      d = dog(breed: :chihuahua)
      5.times { d.train(:sit, :kitchen) }
      expect([d.responds_to?(:sit, :kitchen), d.responds_to?(:sit, :park)]).to eq([true, false])
    end
  end

  describe '#react_to' do
    it '高ぶりと快・不快を別々に保持すること' do
      d = dog.tap { |dog| dog.react_to(arousal: 80, valence: -50) }
      expect([d.aroused?, d.pleased?]).to eq([true, false])
    end
  end

  describe '#human_equivalent_age' do
    it '極端に若くても破綻せず正の整数を返すこと' do
      expect(dog(age_in_days: 5).human_equivalent_age).to be_an(Integer)
    end
  end

  describe '犬種・ライフステージへの委譲と派生述語' do
    it '成熟・運動・被毛・睡眠・体温などを犬種/ステージから導くこと' do
      d = dog(age_in_days: 800)
      saint = dog(breed: :saint_bernard)
      derived = [
        d.sexually_mature?, d.socially_mature?, d.safe_for_high_impact_exercise?,
        d.daily_water_need_ml.positive?, d.recommended_meals_per_day.positive?,
        d.daily_sleep_hours_needed.positive?, d.heat_tolerance_celsius.is_a?(Integer),
        d.cold_tolerance_celsius.is_a?(Integer), d.sheds_seasonally?, d.should_not_be_shaved?,
        saint.coat_prone_to_matting?, saint.prone_to_bloat?
      ]
      expect(derived).to all(be_truthy)
    end

    it '体型の述語を BCS に応じて返すこと' do
      flags = [dog(weight_in_grams: 7_200).underweight?, dog.ideal_weight?,
               dog(weight_in_grams: 10_800).overweight?, dog(weight_in_grams: 12_600).obese?]
      expect(flags).to eq([true, true, true, true])
    end

    it 'at_risk_of_heatstroke? / predisposed_to? / death を返すこと' do
      expect([dog(breed: :french_bulldog).at_risk_of_heatstroke?(25), dog.predisposed_to?(:atopy), dog.death])
        .to eq([true, true, nil])
    end
  end

  describe '#expose_to_threat / #exercise_soon_after_eating' do
    it '脅威は信頼を下げ、食後すぐの運動は素因犬で胃捻転リスクになること' do
      d = dog
      before = d.trust
      d.expose_to_threat
      flags = [d.trust < before, dog(breed: :saint_bernard).tap(&:exercise_soon_after_eating).at_acute_bloat_risk?]
      expect(flags).to eq([true, true])
    end
  end
end
