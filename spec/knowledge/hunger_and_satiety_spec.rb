# frozen_string_literal: true

# ドメイン知識: 空腹と満腹
#
# 空腹は「いま食べたいか」という短期のシグナルで、体型(長期のエネルギー収支)とは別物。
#
# 獣医・栄養学の専門知識:
#   - 理想体型の犬でも食間には空腹になる。空腹度と体型(BCS)は独立。
#   - 子犬は胃が小さく低血糖を起こしやすいため、成犬より食事回数を多くする。
#   - 胸の深い大型犬は早食い・大量の一度食いで胃捻転(GDV)を起こすリスク体質。
RSpec.describe '空腹と満腹' do
  def dog(breed:, weight_g: nil)
    Kennel::Domain::Dog.new(
      breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed),
      age_in_days: 400,
      weight_in_grams: weight_g
    )
  end

  def puppy(breed:)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed), age_in_days: 90)
  end

  describe '空腹は体型とは別の短期シグナル' do
    context '理想体型の犬でも時間が経つと' do
      it '体型は理想のまま、空腹になること' do
        d = dog(breed: :shiba) # 理想体重で生成
        d.get_hungrier(60)
        expect([d.ideal_weight?, d.hungry?]).to eq([true, true])
      end
    end

    context '食事をとると' do
      it '空腹が満たされること' do
        d = dog(breed: :shiba)
        d.get_hungrier(80)
        expect { d.eat(50) }.to(change { d.hungry? }.from(true).to(false))
      end
    end
  end

  describe '必要な食事回数はライフステージで変わる' do
    context '子犬は胃が小さく低血糖を起こしやすいので' do
      it '成犬より多い食事回数が推奨されること' do
        expect(puppy(breed: :shiba).recommended_meals_per_day)
          .to be > dog(breed: :shiba).recommended_meals_per_day
      end
    end
  end

  describe '胸の深い大型犬は胃捻転(GDV)のリスクがある' do
    context '胸の深い大型犬(セントバーナード)は' do
      it '胃捻転のリスク体質であること' do
        expect(dog(breed: :saint_bernard).prone_to_bloat?).to be(true)
      end
    end

    context '小型犬(チワワ)は' do
      it '胃捻転のリスク体質ではないこと' do
        expect(dog(breed: :chihuahua).prone_to_bloat?).to be(false)
      end
    end
  end

  # 胃捻転は「素因(胸の深い大型犬)」に「引き金(早食い・大量の一度食い・食後すぐの運動)」が
  # 加わって起きる。素因だけでも引き金だけでも急性リスクにはならない。
  describe '胃捻転は素因に引き金が加わって起きる' do
    context '胸の深い大型犬が大量の餌を早食いすると' do
      it '胃捻転の急性リスクが生じること' do
        expect(dog(breed: :saint_bernard).tap(&:bolt_large_meal).at_acute_bloat_risk?).to be(true)
      end
    end

    context '胸の深い大型犬が食後すぐに運動すると' do
      it '胃捻転の急性リスクが生じること' do
        expect(dog(breed: :saint_bernard).tap(&:exercise_soon_after_eating).at_acute_bloat_risk?).to be(true)
      end
    end

    context '同じ引き金でも素因のない小型犬では' do
      it '胃捻転の急性リスクは生じないこと' do
        expect(dog(breed: :chihuahua).tap(&:bolt_large_meal).at_acute_bloat_risk?).to be(false)
      end
    end

    context '素因があっても、ゆっくり普通に食べる分には' do
      it '急性リスクは生じないこと' do
        expect(dog(breed: :saint_bernard).tap { |d| d.eat(30) }.at_acute_bloat_risk?).to be(false)
      end
    end
  end
end
