# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class TrainDog < CommandHandler
        def call(command)
          dog = load!(command.dog_id)
          dog.train(command.cue, command.context)
          @dogs.save(dog)
        end
      end
    end
  end
end
