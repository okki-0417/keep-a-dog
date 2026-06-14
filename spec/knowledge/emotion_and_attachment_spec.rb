# frozen_string_literal: true

# ドメイン知識: 情動と愛着
#
# 犬と飼い主の関係は「幸福度メーター」ではなく、信頼にもとづく愛着で捉える。
#
# 行動学の専門知識:
#   - 信頼は予測可能で安心できる関わりから育つ。罰(嫌悪刺激)や不意の脅威は、
#     関係を「支配」するのではなく、信頼そのものを損なう。
#   - 情動は「高ぶり(arousal)」と「快・不快(valence)」の別々の軸で捉える。
#     高ぶっている=幸福、ではない(恐怖でも高ぶる)。
RSpec.describe '情動と愛着' do
  def dog
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: 400)
  end

  describe '信頼は安心できる関わりで育ち、罰や脅威で損なわれる' do
    context '予測可能で穏やかな関わりを重ねると' do
      it '信頼が育ち、安定した愛着が形成されること' do
        d = dog
        5.times { d.reassure }
        expect(d.securely_attached?).to be(true)
      end
    end

    context '罰(嫌悪刺激)を与えると' do
      it '関係を支配するのではなく、信頼が損なわれること' do
        d = dog
        expect { d.punish }.to(change { d.trust }.by(a_value < 0))
      end
    end

    context '不意の脅威にさらされると' do
      it '信頼が損なわれること' do
        d = dog
        before = d.trust
        d.expose_to_threat
        expect(d.trust).to be < before
      end
    end
  end

  describe '高ぶり(arousal)と快・不快(valence)は別の軸' do
    context '恐怖で高ぶっているとき' do
      it '高ぶってはいるが、快ではないこと(興奮=幸福ではない)' do
        d = dog
        d.react_to(arousal: 80, valence: -70)
        expect([d.aroused?, d.pleased?]).to eq([true, false])
      end
    end

    context '遊びで高ぶっているとき' do
      it '高ぶっていて、かつ快であること' do
        d = dog
        d.react_to(arousal: 80, valence: 60)
        expect([d.aroused?, d.pleased?]).to eq([true, true])
      end
    end
  end
end
