# frozen_string_literal: true

# ドメイン知識: 学習と般化
#
# しつけはオペラント条件づけで、芸は「習得 → 般化」と進む。
#
# 行動学の専門知識:
#   - 芸は文脈ごとに学習される。台所で覚えた「おすわり」は、初めての公園では
#     すぐにはできない。文脈をまたいで再現できるようになることを「般化」と呼ぶ。
#   - 複数の文脈で練習を重ねると般化し、未経験の文脈でもできるようになる。
#   - 習得の速さは気質(従順性)で変わり、独立心が強い犬種は多くの反復を要する。
RSpec.describe '学習と般化' do
  def dog(breed: :chihuahua)
    Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(breed), age_in_days: 400)
  end

  def train_until_fluent(dog, cue, context)
    sessions = 0
    until dog.fluent?(cue, context)
      dog.train(cue, context)
      sessions += 1
    end
    sessions
  end

  describe '芸は文脈ごとに学習される' do
    context '台所で覚えた芸を、まだ練習していない文脈で求めると' do
      it '練習した台所ではできるが、初めての公園ではまだできないこと' do
        d = dog
        train_until_fluent(d, :sit, :kitchen)
        expect([d.responds_to?(:sit, :kitchen), d.responds_to?(:sit, :park)]).to eq([true, false])
      end
    end
  end

  describe '複数の文脈で練習すると般化する' do
    context '異なる3つの文脈で習得すると' do
      it '一度も練習していない新しい文脈でもできるようになること' do
        d = dog
        %i[kitchen park street].each { |context| train_until_fluent(d, :sit, context) }
        expect(d.responds_to?(:sit, :vet_clinic)).to be(true)
      end
    end
  end

  describe '習得の速さは気質(従順性)で変わる' do
    context '独立心が強い犬種は' do
      it '従順な犬種より習得に多くの反復を要すること(柴犬 > チワワ)' do
        shiba_sessions = train_until_fluent(dog(breed: :shiba), :sit, :kitchen)
        chihuahua_sessions = train_until_fluent(dog(breed: :chihuahua), :sit, :kitchen)
        expect(shiba_sessions).to be > chihuahua_sessions
      end
    end
  end
end
