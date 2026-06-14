# frozen_string_literal: true

# ドメイン知識: 睡眠と休息
#
# 犬は多相性睡眠で、必要な睡眠時間はライフステージで変わる。
#
# 専門知識:
#   - 成犬の睡眠は1日およそ12〜14時間。子犬と老犬はさらに長く、18時間前後を要する。
RSpec.describe '睡眠と休息' do
  def dog(age_in_days)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: age_in_days)
  end

  describe '必要な睡眠時間' do
    context '子犬や老犬は' do
      it '成犬より多くの睡眠を必要とすること' do
        puppy = dog(60)
        adult = dog(400)
        senior = dog(4_500)
        expect([puppy.daily_sleep_hours_needed > adult.daily_sleep_hours_needed,
                senior.daily_sleep_hours_needed > adult.daily_sleep_hours_needed]).to eq([true, true])
      end
    end
  end
end
