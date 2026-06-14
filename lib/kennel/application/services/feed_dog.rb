# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class FeedDog < CommandHandler
        def call(command)
          dog = load!(command.dog_id)
          dog.eat(command.satiety)
          dog.bolt_large_meal if command.gulped
          @dogs.save(dog)
        end
      end
    end
  end
end
