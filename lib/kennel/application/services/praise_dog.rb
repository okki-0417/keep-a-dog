# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class PraiseDog < CommandHandler
        def call(command)
          dog = load!(command.dog_id)
          dog.reassure
          @dogs.save(dog)
        end
      end
    end
  end
end
