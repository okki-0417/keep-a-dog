# frozen_string_literal: true

module Kennel
  module Application
    module Services
      # 一日の経過を束ねるユースケース。加齢・エネルギー収支・空腹という別々のドメイン知識を、
      # 「その日に与えたエネルギー(intake_kcal)」を入力に1日ぶん進める。
      class LiveADay < CommandHandler
        DAILY_APPETITE = 40

        def call(command)
          dog = load!(command.dog_id)
          dog.pass_day(1)
          dog.metabolize(command.intake_kcal)
          dog.get_hungrier(DAILY_APPETITE)
          @dogs.save(dog)
        end
      end
    end
  end
end
