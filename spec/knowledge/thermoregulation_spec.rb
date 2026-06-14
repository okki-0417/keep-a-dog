# frozen_string_literal: true

# ドメイン知識: 体温調節
#
# 犬は汗腺がほとんどなく、主にパンティング(あえぎ呼吸)で熱を逃がす。
# どれだけ暑さ・寒さに耐えられるかは、被毛・体格・頭部の形で決まる。
#
# 獣医の専門知識:
#   - ダブルコート(二重被毛)は断熱性が高く、寒さに強く暑さに弱い。
#   - 体格が大きいほど体表面積/体重比が小さく、放熱が苦手で暑さに弱い。
#   - 短頭種(フレンチブルドッグ等)は気道が狭く(BOAS)パンティングが効きにくいため、
#     軽い暑さでも熱中症になりやすい。
RSpec.describe '体温調節' do
  def dog(breed)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed), age_in_days: 400)
  end

  describe '被毛による耐暑・耐寒' do
    context 'ダブルコートの犬は' do
      it '短毛の犬より寒さに強く、暑さに弱いこと' do
        double_coat = dog(:shiba)        # ダブルコート
        short_coat = dog(:chihuahua)     # 短毛
        expect(double_coat.cold_tolerance_celsius).to be < short_coat.cold_tolerance_celsius
        expect(double_coat.heat_tolerance_celsius).to be < short_coat.heat_tolerance_celsius
      end
    end
  end

  describe '体格による耐暑' do
    context '体格が大きい犬種ほど' do
      it '放熱が苦手で暑さに弱いこと(セントバーナードはチワワより低い気温で暑がる)' do
        expect(dog(:saint_bernard).heat_tolerance_celsius).to be < dog(:chihuahua).heat_tolerance_celsius
      end
    end
  end

  describe '短頭種(BOAS)の熱中症リスク' do
    context '短頭種(フレンチブルドッグ)は気道が狭くパンティングが効きにくいので' do
      it '中型犬と同程度の体格でも、軽い暑さで熱中症リスクが高いこと' do
        frenchie = dog(:french_bulldog)
        shiba = dog(:shiba)
        expect(frenchie.heat_tolerance_celsius).to be < shiba.heat_tolerance_celsius
      end

      it '25℃程度の暑さでも熱中症の危険があること' do
        expect(dog(:french_bulldog).at_risk_of_heatstroke?(25)).to be(true)
      end
    end

    context '短頭でない犬(柴犬)は' do
      it '25℃では熱中症の危険がないこと' do
        expect(dog(:shiba).at_risk_of_heatstroke?(25)).to be(false)
      end
    end
  end
end
