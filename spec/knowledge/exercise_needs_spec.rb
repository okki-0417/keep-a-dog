# frozen_string_literal: true

# ドメイン知識: 運動の必要量
#
# 必要な運動量は犬種・年齢で違い、満たされないと問題が起きる。
#
# トレーナー・行動学の専門知識:
#   - 活発な犬種ほど多くの運動を必要とする。
#   - 運動が足りないと、あり余ったエネルギーが問題行動になる("a tired dog is a good dog")。
RSpec.describe '運動の必要量' do
  def dog(breed: :shiba)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed), age_in_days: 400)
  end

  describe '犬種で必要運動量が違う' do
    context '活発な犬種ほど' do
      it '一日の必要運動量が多いこと(柴犬 > チワワ)' do
        expect(dog.daily_exercise_need_minutes).to be > dog(breed: :chihuahua).daily_exercise_need_minutes
      end
    end
  end

  describe '運動不足は問題行動につながる' do
    context '必要量を満たすと' do
      it '満たされて、問題行動のリスクが無いこと' do
        d = dog
        d.exercise(d.daily_exercise_need_minutes)
        expect([d.well_exercised?, d.at_risk_of_problem_behavior?]).to eq([true, false])
      end
    end

    context '必要量に満たない運動しかしないと' do
      it 'あり余ったエネルギーで問題行動のリスクが高まること' do
        d = dog
        d.exercise(d.daily_exercise_need_minutes - 30)
        expect(d.at_risk_of_problem_behavior?).to be(true)
      end
    end
  end
end
