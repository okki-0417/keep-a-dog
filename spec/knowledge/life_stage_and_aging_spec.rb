# frozen_string_literal: true

# ドメイン知識: ライフステージと加齢
#
# 犬は時間とともに歳をとり、子犬→青年→成犬→老犬とライフステージが移る。
# その境界は犬種ごとの「性成熟の時期」と「寿命」で決まる。
#
# 獣医・育種の専門知識:
#   - 「成熟」は一つではない。性成熟・骨格成熟・社会的成熟は時期が異なり、
#     体格が大きい犬種ほど性成熟と骨格成熟が大きく離れる。
#   - 老齢期は「寿命の最後の約25%」と定義される(AAHAライフステージ)。
#   - 犬の年齢は人間換算で単純な×7ではなく、対数的(若い時期ほど速く老ける)。
RSpec.describe 'ライフステージと加齢' do
  def dog(breed, age_in_days)
    Kennel::Domain::Dog.new(
      breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed),
      age_in_days: age_in_days
    )
  end

  def breed(key)
    Kennel::Domain::Breed::BreedCatalog.fetch(key)
  end

  # 柴犬: 性成熟365日 / 老齢4106日(寿命の75%) / 寿命5475日
  describe 'ライフステージの移り変わり' do
    context '生後すぐ、性成熟の半ば(柴犬で182日)に達するまで' do
      it '子犬であること' do
        expect(dog(:shiba, 90).life_stage.label).to eq('子犬')
      end
    end

    context '性成熟の半ばを過ぎ、性成熟に達するまで' do
      it '青年であること' do
        expect(dog(:shiba, 200).life_stage.label).to eq('青年')
      end
    end

    context '性成熟を迎えてから、老齢に入るまで' do
      it '成犬であること' do
        expect(dog(:shiba, 365).life_stage.label).to eq('成犬')
      end
    end

    context '寿命の最後の25%(老齢期)に入ると' do
      it '老犬であること' do
        expect(dog(:shiba, 4500).life_stage.label).to eq('老犬')
      end
    end
  end

  describe '性成熟' do
    context '性成熟日齢に達する前(柴犬で364日)' do
      it 'まだ性成熟していないこと' do
        expect(dog(:shiba, 364).sexually_mature?).to be(false)
      end
    end

    context '性成熟日齢に達すると(柴犬で365日)' do
      it '性成熟したとみなされること' do
        expect(dog(:shiba, 365).sexually_mature?).to be(true)
      end
    end
  end

  describe '3つの成熟(性成熟・骨格成熟・社会的成熟)' do
    context '3つの成熟は同時ではなく、この順に訪れる' do
      it '性成熟 → 骨格成熟 → 社会的成熟 の順であること(柴犬)' do
        shiba = breed(:shiba)
        order = [shiba.maturity_age_days, shiba.skeletal_maturity_age_days, shiba.social_maturity_age_days]
        expect(order).to eq(order.sort)
      end
    end

    context '体格が大きい犬種ほど' do
      it '性成熟から骨格成熟までの間隔が長いこと(セントバーナード > チワワ)' do
        gap = ->(b) { breed(b).skeletal_maturity_age_days - breed(b).maturity_age_days }
        expect(gap.call(:saint_bernard)).to be > gap.call(:chihuahua)
      end
    end

    context '大型犬は性成熟を迎えても骨格はまだ成長途中' do
      it 'セントバーナードは生後600日で性成熟していても骨格は未成熟であること' do
        st = dog(:saint_bernard, 600)
        expect([st.sexually_mature?, st.skeletally_mature?]).to eq([true, false])
      end
    end

    context '骨格が未成熟なうちは(成長板が閉じていない)' do
      it '高負荷の運動を避けるべき状態であること、骨格成熟で解除されること' do
        expect(dog(:saint_bernard, 600).safe_for_high_impact_exercise?).to be(false)
        expect(dog(:saint_bernard, 800).safe_for_high_impact_exercise?).to be(true)
      end
    end
  end

  describe '体格と加齢の速さ' do
    context '体格が大きい犬種ほど' do
      it '若い日齢で老いること(同じ2500日でもセントバーナードは老犬、柴犬はまだ)' do
        expect(dog(:saint_bernard, 2500).life_stage.label).to eq('老犬')
        expect(dog(:shiba, 2500).life_stage.label).not_to eq('老犬')
      end
    end
  end

  describe '人間に換算した年齢' do
    context '生後1年の犬' do
      it '人間でいう約31歳に相当すること(俗説の×7=7歳ではない)' do
        expect(dog(:shiba, 365).human_equivalent_age).to eq(31)
      end
    end

    context '生後2年の犬' do
      it '人間でいう約42歳に相当すること' do
        expect(dog(:shiba, 730).human_equivalent_age).to eq(42)
      end
    end

    context '若い時期ほど' do
      it '1年あたりの加齢が大きいこと(1→2歳の差 > 5→6歳の差)' do
        early = dog(:shiba, 730).human_equivalent_age - dog(:shiba, 365).human_equivalent_age
        late = dog(:shiba, 2190).human_equivalent_age - dog(:shiba, 1825).human_equivalent_age
        expect(early).to be > late
      end
    end
  end

  describe '寿命と死' do
    context '寿命(柴犬5475日)を超えて歳をとると' do
      it '老衰で亡くなること' do
        old = dog(:shiba, 5474).pass_day(1)
        expect([old.dead?, old.death.label]).to eq([true, '老衰'])
      end
    end

    context '亡くなった後に時間が流れても' do
      it 'もう歳をとらないこと' do
        dead = dog(:shiba, 5474).pass_day(1)
        expect { dead.pass_day(10) }.not_to(change { dead.age_in_days })
      end
    end
  end

  describe '時の経過' do
    context '1日進めると' do
      it '日齢が1日ぶん増えること(100→101)' do
        expect(dog(:shiba, 100).pass_day.age_in_days).to eq(101)
      end
    end

    context '複数日まとめて進めると' do
      it '日齢がその日数ぶん増えること(100→103)' do
        expect(dog(:shiba, 100).pass_day(3).age_in_days).to eq(103)
      end
    end
  end
end
