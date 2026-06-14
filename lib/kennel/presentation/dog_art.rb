# frozen_string_literal: true

module Kennel
  module Presentation
    # 犬の観察可能な福祉サイン(空腹・脱水・痛み・不安・愛着など)から、表情つきの姿を選ぶ。
    # 内部の隠し状態ではなく「外から見える様子」を映すので、痛みを隠していれば穏やかに見える。
    module DogArt
      FACES = {
        happy:    " ∩   ∩\n( ^ᴥ^ )♪\n ∪ ─ ∪\n  ごきげん",
        content:  " ∩   ∩\n( ･ᴥ･ )\n ∪ ─ ∪\n  ふつう",
        hungry:   " ∩   ∩\n( ･ᴥ･ )?\n ∪ ─ ∪\n  おねだり",
        sad:      " ∩   ∩\n( ´•ᴥ•)…\n ∪ ─ ∪\n  しょんぼり",
        sick:     " ∩   ∩\n( ×ᴥ× )\n ～ ─ ～\n  ぐったり",
        wary:     " ∩   ∩\n( ｀ᴥ´ )ｳｰ\n ∪ ─ ∪\n  けいかい",
        memorial: "   ╱╲\n ( ╥ᴥ╥ )\n   🌈\n  旅立ち"
      }.freeze

      module_function

      def for(dog)
        FACES.fetch(mood(dog))
      end

      def mood(dog)
        return :memorial if dog.dead?
        return :sick if dog.sick? || dog.obviously_in_pain?
        return :wary if dog.fearful? || dog.separation_anxiety?
        return :sad if dog.dehydrated? || dog.underweight?
        return :hungry if dog.hungry?
        return :happy if dog.securely_attached? && dog.well_exercised?

        :content
      end
    end
  end
end
