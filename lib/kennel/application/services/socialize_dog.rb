# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class SocializeDog < CommandHandler
        def call(command)
          dog = load!(command.dog_id)
          dog.socialize
          @dogs.save(dog)
        end
      end
    end
  end
end
