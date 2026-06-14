# frozen_string_literal: true

# ドメイン知識: 健康と病気
#
# 病気は単一のHPバーではなく、個々の疾患として捉える。
#
# 獣医の専門知識:
#   - 急性の病気は治療で完治しうるが、慢性の病気は完治せず「管理」しながら付き合う。
#   - 犬種ごとに遺伝的に罹りやすい病気(素因)がある。ただし素因は確定した運命ではなく、
#     発症するまでは病気ではない(ベースのリスク)。
RSpec.describe '健康と病気' do
  def dog(breed: :shiba)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed), age_in_days: 400)
  end

  def condition(key)
    Kennel::Domain::Medical::ConditionCatalog.fetch(key)
  end

  describe '急性と慢性で治療の意味が違う' do
    context '急性の病気(ケンネルコフ)を治療すると' do
      it '完治して、もう患っていないこと' do
        d = dog
        d.fall_ill(condition(:kennel_cough))
        d.treat
        expect(d.sick?).to be(false)
      end
    end

    context '慢性の病気(股関節形成不全)を治療しても' do
      it '完治はせず、管理しながら付き合い続けること' do
        d = dog
        d.fall_ill(condition(:hip_dysplasia))
        d.treat
        expect(d.suffers_from?(:hip_dysplasia)).to be(true)
      end
    end
  end

  describe '犬種ごとに遺伝的に罹りやすい病気がある' do
    context '大型犬(セントバーナード)は' do
      it '股関節形成不全の遺伝的素因を持つこと' do
        expect(dog(breed: :saint_bernard).predisposed_to?(:hip_dysplasia)).to be(true)
      end
    end

    context '小型犬(チワワ)は' do
      it '膝蓋骨脱臼の素因を持つが、股関節形成不全の素因は持たないこと' do
        chihuahua = dog(breed: :chihuahua)
        expect([chihuahua.predisposed_to?(:patellar_luxation), chihuahua.predisposed_to?(:hip_dysplasia)])
          .to eq([true, false])
      end
    end
  end

  describe '素因は確定した運命ではない' do
    context '素因を持つ犬でも、まだ発症していなければ' do
      it '素因は持つが、今は病気ではないこと' do
        d = dog(breed: :saint_bernard)
        expect([d.predisposed_to?(:hip_dysplasia), d.sick?]).to eq([true, false])
      end
    end
  end
end
