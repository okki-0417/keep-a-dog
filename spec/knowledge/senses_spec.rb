# frozen_string_literal: true

# ドメイン知識: 犬の感覚
#
# 犬の世界の捉え方は人間と大きく違う。
#
# 専門知識(俗説の訂正):
#   - 視覚は「白黒」ではなく二色型色覚。青と黄は見えるが、赤と緑は区別しにくい。
#   - 聴覚は人間の可聴域(約2万Hz)を超え、超音波域(およそ4.5万Hzまで)が聞こえる。
#   - 嗅覚は人間より桁違いに鋭い(数万倍とされる)。
RSpec.describe '犬の感覚' do
  let(:senses) { Kennel::Domain::Senses }

  describe '視覚' do
    context '犬は二色型色覚を持つ' do
      it '青や黄は見えるが、赤は区別できないこと(白黒ではない)' do
        expect([senses.sees_color?(:blue), senses.sees_color?(:yellow), senses.sees_color?(:red)])
          .to eq([true, true, false])
      end

      it '色覚は単色型(白黒)ではなく二色型であること' do
        expect(senses.color_vision).to eq(:dichromatic)
      end
    end
  end

  describe '聴覚' do
    context '超音波域まで聞こえる' do
      it '人間の可聴域を超える4万Hzでも聞こえること' do
        expect(senses.hears_frequency?(40_000)).to be(true)
      end

      it '4.5万Hzを大きく超える6万Hzは聞こえないこと' do
        expect(senses.hears_frequency?(60_000)).to be(false)
      end
    end
  end

  describe '嗅覚' do
    context '嗅覚が突出して鋭い' do
      it '人間の1万倍以上の感度を持つこと' do
        expect(senses.smell_sensitivity_factor).to be >= 10_000
      end
    end
  end
end
