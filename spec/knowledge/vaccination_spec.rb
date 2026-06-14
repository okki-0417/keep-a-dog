# frozen_string_literal: true

# ドメイン知識: ワクチンと予防接種
#
# 子犬のワクチンは、母から受け継いだ移行抗体の影響で「一度打てば終わり」ではない。
#
# 獣医の専門知識:
#   - 移行抗体はワクチンの効きを妨げる。いつ消えるか個体差があるため、子犬期は時期を
#     ずらした連続接種(シリーズ)を行う。移行抗体が消えた後なら単回で免疫がつく。
#   - 狂犬病ワクチンは法的に義務づけられている(コアワクチン)。
RSpec.describe 'ワクチンと予防接種' do
  def dog(age_in_days)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: age_in_days)
  end

  describe '移行抗体と子犬の連続接種' do
    context '移行抗体が残る幼い子犬(生後8週)は' do
      it '一度の接種では免疫がつかないこと' do
        puppy = dog(56)
        puppy.vaccinate(:distemper)
        expect(puppy.immune_to?(:distemper)).to be(false)
      end

      it '時期をずらした連続接種(3回)で初めて免疫がつくこと' do
        puppy = dog(56)
        3.times { puppy.vaccinate(:distemper) }
        expect(puppy.immune_to?(:distemper)).to be(true)
      end
    end

    context '移行抗体が消えた成犬(生後400日)は' do
      it '一度の接種で免疫がつくこと' do
        adult = dog(400)
        adult.vaccinate(:distemper)
        expect(adult.immune_to?(:distemper)).to be(true)
      end
    end
  end

  describe '法的に義務づけられたワクチン' do
    context '狂犬病ワクチンは' do
      it '法的に義務づけられていること(任意のワクチンとは違う)' do
        expect([Kennel::Domain::Vaccines.legally_required?(:rabies),
                Kennel::Domain::Vaccines.legally_required?(:kennel_cough)]).to eq([true, false])
      end
    end
  end
end
