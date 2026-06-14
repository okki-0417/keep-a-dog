# frozen_string_literal: true

# ドメイン知識: 歯と口腔
#
# 犬の歯は乳歯から永久歯へ生え替わり、口腔ケアを怠ると歯周病になる。
#
# 獣医の専門知識:
#   - 子犬の乳歯は28本、成犬の永久歯は42本。生後およそ3〜7ヶ月で生え替わる。
#   - 歯周病は犬で最も多い病気。歯磨きを怠ると歯石がたまり、リスクが高まる。
RSpec.describe '歯と口腔' do
  def dog(age_in_days)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: age_in_days)
  end

  describe '乳歯と永久歯' do
    context '生え替わり前の子犬は' do
      it '乳歯28本であること' do
        expect(dog(60).tooth_count).to eq(28)
      end
    end

    context '生え替わりを終えた成犬は' do
      it '永久歯42本であること' do
        expect(dog(400).tooth_count).to eq(42)
      end
    end
  end

  describe '歯の生え替わり' do
    context '生後3〜7ヶ月ごろは' do
      it '歯の生え替わり期であること' do
        expect(dog(150).teething?).to be(true)
      end
    end
  end

  describe '歯石と歯周病' do
    context '歯磨きを怠って歯石がたまると' do
      it '歯周病のリスクが高まること' do
        d = dog(400)
        d.neglect_dental_care(80)
        expect(d.at_risk_of_periodontal_disease?).to be(true)
      end
    end

    context '歯を磨くと' do
      it '歯石が落ちてリスクが下がること' do
        d = dog(400)
        d.neglect_dental_care(80)
        expect { d.brush_teeth }.to(change { d.at_risk_of_periodontal_disease? }.from(true).to(false))
      end
    end
  end
end
