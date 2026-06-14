# frozen_string_literal: true

# ドメイン知識: 痛みを隠す
#
# 犬は捕食される側の本能から、痛みや不調を隠す。だから「はっきりした症状が無い=健康」
# ではない。飼い主が気づいたときには進行していることが多い。
#
# 獣医の専門知識:
#   - 中等度の痛みでは、犬ははっきりした素振りを見せず隠す。
#   - 痛みが強くなって初めて、誰の目にも分かる様子が現れる。
RSpec.describe '痛みを隠す' do
  def dog
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: 400)
  end

  describe '犬は痛みを隠す' do
    context '中等度の痛みを抱えているとき' do
      it '痛みはあるのに、はっきりした素振りは見せないこと(隠している)' do
        d = dog
        d.experience_pain(40)
        expect([d.in_pain?, d.obviously_in_pain?, d.masking_pain?]).to eq([true, false, true])
      end
    end

    context '痛みが強くなると' do
      it 'さすがに誰の目にも分かる痛みの様子が現れること' do
        d = dog
        d.experience_pain(80)
        expect(d.obviously_in_pain?).to be(true)
      end
    end
  end

  describe '見た目だけでは健康を判断できない' do
    context 'はっきりした痛みの様子が無い犬でも' do
      it '実際には痛みを抱えていることがあること(症状が出ない=健康ではない)' do
        d = dog
        d.experience_pain(40)
        expect([d.obviously_in_pain?, d.in_pain?]).to eq([false, true])
      end
    end
  end
end
