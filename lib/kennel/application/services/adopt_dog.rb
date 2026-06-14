# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class AdoptDog < CommandHandler
        def call(command)
          dog = Domain::Dog.new(
            breed: Domain::Breed::BreedCatalog.fetch(command.breed_key),
            age_in_days: command.age_in_days
          )
          @dogs.save(dog)
        end
      end
    end
  end
end
