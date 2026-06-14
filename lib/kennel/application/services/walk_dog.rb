# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class WalkDog < CommandHandler
        def call(command)
          dog = load!(command.dog_id)
          dog.exercise(command.minutes)
          @dogs.save(dog)
        end
      end
    end
  end
end
