# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class TreatDog < CommandHandler
        def call(command)
          dog = load!(command.dog_id)
          dog.treat
          @dogs.save(dog)
        end
      end
    end
  end
end
