# frozen_string_literal: true

# ドメイン知識: 被毛と換毛
#
# 被毛の種類によって、換毛・トリミング・手入れの要点が変わる。
#
# トリマー・獣医の専門知識:
#   - ダブルコート(二重被毛)は季節の変わり目に大量に換毛する("毛が抜け替わる")。
#   - ダブルコートは刈ってはいけない。断熱・体温調節が損なわれ、生え方も乱れる。
#   - 長毛は手入れを怠ると毛玉(マット)ができやすい。
RSpec.describe '被毛と換毛' do
  def dog(breed)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed), age_in_days: 400)
  end

  describe '換毛' do
    context 'ダブルコートの犬は' do
      it '季節の変わり目に大量に換毛すること(短毛のチワワはしない)' do
        expect([dog(:shiba).sheds_seasonally?, dog(:chihuahua).sheds_seasonally?]).to eq([true, false])
      end
    end
  end

  describe 'トリミングの可否' do
    context 'ダブルコートは' do
      it '刈ってはいけないこと(断熱が損なわれる)' do
        expect(dog(:shiba).should_not_be_shaved?).to be(true)
      end
    end
  end

  describe '毛玉' do
    context '長毛の犬は手入れを怠ると' do
      it '毛玉ができやすいこと(短毛のチワワは起きにくい)' do
        expect([dog(:saint_bernard).coat_prone_to_matting?, dog(:chihuahua).coat_prone_to_matting?]).to eq([true, false])
      end
    end
  end
end
