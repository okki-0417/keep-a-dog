# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class NeuterDog < CommandHandler
        def call(command)
          dog = load!(command.dog_id)
          dog.neuter
          @dogs.save(dog)
        end
      end
    end
  end
end
