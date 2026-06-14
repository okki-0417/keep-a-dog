# frozen_string_literal: true

# ドメイン知識: 問題行動(分離不安)
#
# 分離不安は「留守番中の破壊や鳴き」として現れるが、しつけ不足や反抗ではなく不安が原因。
#
# 行動学の専門知識:
#   - 突然の長時間の留守番は分離不安を生む。
#   - 段階的な慣らし(脱感作)で留守番への耐性が上がり、不安が生じにくくなる。
#   - 罰は分離不安を悪化させる(叱っても直らない。むしろ不安を強める)。
RSpec.describe '問題行動(分離不安)' do
  def dog
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: 400)
  end

  describe '留守番と分離不安' do
    context '耐性のない犬を突然8時間留守番させると' do
      it '分離不安に陥ること' do
        d = dog
        d.left_alone(8)
        expect(d.separation_anxiety?).to be(true)
      end
    end
  end

  describe '脱感作(段階的な慣らし)' do
    context '少しずつ留守番に慣らして耐性を上げると' do
      it '同じ8時間の留守番でも分離不安に陥らないこと' do
        d = dog
        4.times { d.desensitize_to_absence }
        d.left_alone(8)
        expect(d.separation_anxiety?).to be(false)
      end
    end
  end

  describe '罰の逆効果' do
    context '不安を抱えた犬を叱ると' do
      it '分離不安が悪化すること(叱っても直らない)' do
        d = dog
        d.left_alone(6)
        expect { d.punish }.to(change { d.separation_distress }.by(a_value > 0))
      end
    end
  end
end
