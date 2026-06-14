# frozen_string_literal: true

# ドメイン知識: 水分と脱水
#
# 犬は新鮮な水を常に必要とし、失った水分を補えないと脱水に陥る。脱水は命に関わる。
#
# 獣医の専門知識:
#   - 一日の必要飲水量は体重に比例する(体重1kgあたりおよそ50〜60ml)。
#   - 暑さ・病気(嘔吐・下痢)などで水分を失い、補えないと脱水になる。
RSpec.describe '水分と脱水' do
  def dog(breed: :shiba)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed), age_in_days: 400)
  end

  describe '必要な飲水量は体重に比例する' do
    context '体格が大きいほど' do
      it '一日の必要飲水量が多いこと(体重1kgあたり約55ml。柴犬9kgで約495ml)' do
        expect(dog.daily_water_need_ml).to eq(495)
        expect(dog(breed: :saint_bernard).daily_water_need_ml).to be > dog.daily_water_need_ml
      end
    end
  end

  describe '脱水' do
    context '水分を失って補わないと' do
      it '脱水状態になること' do
        d = dog
        d.lose_water(40)
        expect(d.dehydrated?).to be(true)
      end
    end

    context '水を飲むと' do
      it '脱水から回復すること' do
        d = dog
        d.lose_water(40)
        expect { d.give_water }.to(change { d.dehydrated? }.from(true).to(false))
      end
    end
  end
end
