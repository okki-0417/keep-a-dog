# frozen_string_literal: true

# ドメイン知識: 生殖ステータス(去勢・避妊)
#
# 犬が未去勢/未避妊(intact)か、去勢/避妊済み(neutered)かは、犬の生涯に広く影響する。
#
# 獣医の専門知識:
#   - 去勢・避妊をすると必要エネルギーが約25〜30%下がる。気づかず同じ量を与えると肥満になる。
#   - 生殖に関わる病気のリスクが変わる。未避妊のメスは子宮蓄膿症、未去勢のオスは前立腺の
#     リスクを負う。避妊は乳腺腫瘍や子宮蓄膿症のリスクを下げる。
#   - 骨格成熟より前の早期の去勢・避妊は、成長板の閉鎖を遅らせる。
RSpec.describe '生殖ステータス(去勢・避妊)' do
  def dog(sex: :male, age_in_days: 400, breed: :shiba)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed), age_in_days: age_in_days, sex: sex)
  end

  describe '必要エネルギーへの影響' do
    context '去勢・避妊をすると' do
      it '必要エネルギーが下がり、同量を与えると肥満につながること(intactより低い)' do
        expect(dog.tap(&:neuter).maintenance_energy_requirement).to be < dog.maintenance_energy_requirement
      end
    end
  end

  describe '生殖に関わる病気のリスク' do
    context '未避妊のメスは' do
      it '子宮蓄膿症のリスクを負うこと' do
        expect(dog(sex: :female).at_risk_of_pyometra?).to be(true)
      end
    end

    context 'メスを避妊すると' do
      it '子宮蓄膿症と乳腺腫瘍のリスクが下がること' do
        spayed = dog(sex: :female).tap(&:neuter)
        expect([spayed.at_risk_of_pyometra?, spayed.at_risk_of_mammary_tumors?]).to eq([false, false])
      end
    end

    context '未去勢のオスは' do
      it '前立腺の問題のリスクを負うこと' do
        expect(dog(sex: :male).at_risk_of_prostate_problems?).to be(true)
      end
    end
  end

  describe '早期の去勢・避妊と成長板' do
    context '骨格成熟より前に去勢・避妊すると' do
      it '成長板の閉鎖が遅れ、本来成熟する日齢でも骨格はまだ未成熟であること' do
        early_neutered = dog(age_in_days: 200)
        early_neutered.neuter
        early_neutered.pass_day(260) # 460日齢(柴の本来の骨格成熟450日を超える)
        intact = dog(age_in_days: 460)
        expect([early_neutered.skeletally_mature?, intact.skeletally_mature?]).to eq([false, true])
      end
    end
  end
end
