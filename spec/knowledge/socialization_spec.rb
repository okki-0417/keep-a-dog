# frozen_string_literal: true

# ドメイン知識: 社会化
#
# 子犬がさまざまな人・犬・音・環境に触れ、それらを「怖くないもの」として
# 受け入れていく過程が社会化。生涯の気質(自信/怖がり)を大きく左右する。
#
# 行動学の専門知識:
#   - 社会化には臨界期(生後およそ3〜14週)があり、この時期の経験は効果が大きい。
#   - 臨界期を過ぎると社会化は格段に進みにくく、取り戻すのは難しい(ほぼ不可逆)。
RSpec.describe '社会化' do
  def dog(age_in_days)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: age_in_days)
  end

  describe '臨界期の経験は効果が大きい' do
    context '社会化期(生後50日)の子犬と、過ぎた成犬(生後400日)を同じように社会化すると' do
      it '子犬のほうが一度の経験で大きく社会化が進むこと' do
        puppy = dog(50)
        adult = dog(400)
        puppy_gain = puppy.socialize.socialization - 0
        adult_gain = adult.socialize.socialization - 0
        expect(puppy_gain).to be > adult_gain
      end
    end
  end

  describe '臨界期に十分な経験を積めば自信のある気質になる' do
    context '社会化期に4回の経験を積むと' do
      it '十分に社会化された状態になること' do
        puppy = dog(50)
        4.times { puppy.socialize }
        expect(puppy.well_socialized?).to be(true)
      end
    end
  end

  describe '臨界期を逃すと取り戻せない(不可逆)' do
    context '臨界期を過ぎた成犬は同じ回数の経験を積んでも' do
      it '十分には社会化されないこと' do
        adult = dog(400)
        4.times { adult.socialize }
        expect(adult.well_socialized?).to be(false)
      end
    end
  end

  # 恐怖期: 生後8〜11週と思春期。怖い経験が強く刻まれ、生涯の怖がりにつながりやすい。
  describe '恐怖期は怖い経験が強く刻まれる' do
    context '恐怖期(生後9週)の子犬が怖い経験をすると' do
      it '恐怖が強く刻まれ、怖がりになること' do
        puppy = dog(63)
        puppy.scary_experience
        expect(puppy.fearful?).to be(true)
      end
    end

    context '恐怖期でない成犬が同じ怖い経験をしても' do
      it 'それほど刻まれず、怖がりにはならないこと' do
        adult = dog(500)
        adult.scary_experience
        expect(adult.fearful?).to be(false)
      end
    end
  end
end
