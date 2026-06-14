# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class VaccinateDog < CommandHandler
        def call(command)
          dog = load!(command.dog_id)
          dog.vaccinate(command.disease)
          @dogs.save(dog)
        end
      end
    end
  end
end
