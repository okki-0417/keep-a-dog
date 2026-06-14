# frozen_string_literal: true

module Kennel
  module Presentation
    module DogView
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

      def health(dog)
        return '良好' if dog.current_conditions.empty?

        dog.current_conditions.map { |key| Domain::Medical::ConditionCatalog.fetch(key).name }.join('・')
      end
    end
  end
end
