# frozen_string_literal: true

module Kennel
  module Presentation
    # 犬の状態を人が読める文字列に変換する。CLI の一行表示(render)と、
    # TUI のダッシュボードが使う部品(headline / gauges / flags)を提供する。
    module DogView
      BAR_WIDTH = 10
      FILLED = '▓'
      EMPTY = '░'

      module_function

      def render(dog)
        return "🌈 この子は虹の橋を渡りました(#{dog.death.label})" if dog.dead?

        [
          "🐕 #{dog.breed.name}  #{dog.life_stage.label}  人間換算 約#{dog.human_equivalent_age}歳",
          format('  体重 %.1fkg  体型スコア %d/9', dog.weight_in_grams / 1000.0, dog.body_condition_score),
          "  空腹 #{dog.hunger}/100#{dog.hungry? ? '(空腹)' : ''}   信頼 #{dog.trust}/100#{dog.securely_attached? ? '(安定した愛着)' : ''}",
          "  社会化 #{dog.socialization}/100#{dog.well_socialized? ? '(十分)' : ''}",
          "  健康 #{health(dog)}"
        ].join("\n")
      end

      def headline(dog)
        "#{dog.breed.name}・#{dog.life_stage.label}・人間換算 約#{dog.human_equivalent_age}歳"
      end

      def gauges(dog)
        [
          gauge('空腹', dog.hunger),
          gauge('信頼', dog.trust),
          gauge('社会化', dog.socialization),
          gauge('水分', dog.hydration),
          format('体重 %.1fkg  体型 %d/9', dog.weight_in_grams / 1000.0, dog.body_condition_score)
        ]
      end

      # ドメイン上の注意サイン。世話で解消すべきものを拾い上げる。
      def flags(dog)
        flags = []
        flags << 'おなかがすいている' if dog.hungry?
        flags << '脱水ぎみ' if dog.dehydrated?
        flags << '運動不足' if dog.under_exercised?
        flags << '歯石がたまっている' if dog.at_risk_of_periodontal_disease?
        flags << '分離不安のサイン' if dog.separation_anxiety?
        flags << 'こわがっている' if dog.fearful?
        flags << '痛みのサインがはっきり出ている' if dog.obviously_in_pain?
        flags << '痛みを隠しているかもしれない' if dog.masking_pain?
        flags << '⚠ 胃捻転の危険(安静に)' if dog.at_acute_bloat_risk?
        flags << '太りぎみ' if dog.overweight? || dog.obese?
        flags << 'やせぎみ' if dog.underweight?
        flags << "通院中: #{health(dog)}" if dog.sick?
        flags
      end

      def health(dog)
        return '良好' if dog.current_conditions.empty?

        dog.current_conditions.map { |key| Domain::Medical::ConditionCatalog.fetch(key).name }.join('・')
      end

      def gauge(label, value)
        filled = (value / 100.0 * BAR_WIDTH).round
        "#{label.ljust(3)} #{FILLED * filled}#{EMPTY * (BAR_WIDTH - filled)} #{value}/100"
      end
    end
  end
end
