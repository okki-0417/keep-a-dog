# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class GiveWater < CommandHandler
        def call(command)
          dog = load!(command.dog_id)
          dog.give_water
          @dogs.save(dog)
        end
      end
    end
  end
end
