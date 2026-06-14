# frozen_string_literal: true

# ドメイン知識: エネルギー収支
#
# 犬の体重は「摂取エネルギー」と「消費エネルギー」の収支で動く。
#
# 獣医・栄養学の専門知識:
#   - 必要エネルギーは体重そのものでなく代謝体重(体重^0.75)に比例する(RER = 70 × kg^0.75)。
#     そのため小型犬は1kgあたり大型犬よりずっと多くのエネルギーを要する。
#   - 維持に必要な量(MER)は RER にライフステージ等の係数を掛ける(子犬 > 成犬 > 老犬)。
#   - 体型は体重そのものでなく、理想体重との比=ボディ・コンディション・スコア(BCS, 1〜9)で評価し、
#     4〜5/9 が理想。
RSpec.describe 'エネルギー収支' do
  def dog(breed:, weight_g:, age_days: 400)
    Kennel::Domain::Dog.new(
      breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed),
      age_in_days: age_days,
      weight_in_grams: weight_g
    )
  end

  describe '必要エネルギー量' do
    context '体格が違っても代謝体重(体重^0.75)に比例する' do
      it '1kgあたりの必要エネルギーは小型犬のほうが大型犬より多いこと' do
        chihuahua = dog(breed: :chihuahua, weight_g: 2_500)
        saint_bernard = dog(breed: :saint_bernard, weight_g: 70_000)
        expect(chihuahua.resting_energy_requirement / 2.5)
          .to be > (saint_bernard.resting_energy_requirement / 70.0)
      end
    end

    context 'ライフステージによって維持の係数が変わる' do
      it '同じ体重でも子犬は成犬より多くのエネルギーを要すること' do
        puppy = dog(breed: :shiba, weight_g: 9_000, age_days: 90)
        adult = dog(breed: :shiba, weight_g: 9_000, age_days: 400)
        expect(puppy.maintenance_energy_requirement).to be > adult.maintenance_energy_requirement
      end
    end
  end

  describe '体型(ボディ・コンディション・スコア)' do
    context '理想体重のとき' do
      it '体型スコアが理想域(5/9)で、理想体型と判定されること' do
        ideal = dog(breed: :shiba, weight_g: 9_000)
        expect([ideal.body_condition_score, ideal.ideal_weight?]).to eq([5, true])
      end
    end

    context '理想体重を大きく超えると' do
      it '理想の1.2倍で過体重、1.4倍で肥満と判定されること' do
        expect(dog(breed: :shiba, weight_g: 10_800).overweight?).to be(true)
        expect(dog(breed: :shiba, weight_g: 12_600).obese?).to be(true)
      end
    end

    context '理想体重を大きく下回ると' do
      it '理想の0.8倍で痩せと判定されること' do
        expect(dog(breed: :shiba, weight_g: 7_200).underweight?).to be(true)
      end
    end

    context '体型は体重そのものでなく理想体重との比で決まる' do
      it '同じ5kgでもチワワは肥満、柴犬は痩せと判定されること' do
        expect(dog(breed: :chihuahua, weight_g: 5_000).obese?).to be(true)
        expect(dog(breed: :shiba, weight_g: 5_000).underweight?).to be(true)
      end
    end
  end

  describe 'エネルギー収支による体重変化' do
    context '摂取が維持量とちょうど釣り合うと' do
      it '体重が変わらないこと' do
        d = dog(breed: :shiba, weight_g: 9_000)
        expect { d.metabolize(d.maintenance_energy_requirement) }.not_to(change { d.weight_in_grams })
      end
    end

    context '摂取が維持量を上回ると' do
      it '体重が増えること' do
        d = dog(breed: :shiba, weight_g: 9_000)
        before = d.weight_in_grams
        d.metabolize(d.maintenance_energy_requirement + 1_000)
        expect(d.weight_in_grams).to be > before
      end
    end

    context '摂取が維持量を下回ると' do
      it '体重が減ること' do
        d = dog(breed: :shiba, weight_g: 9_000)
        before = d.weight_in_grams
        d.metabolize(d.maintenance_energy_requirement - 1_000)
        expect(d.weight_in_grams).to be < before
      end
    end
  end
end
