# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class CommandHandler
        def initialize(dogs:)
          @dogs = dogs
        end

        private

        def load!(dog_id)
          @dogs.find(dog_id) || raise(Errors::DogNotFound, "犬 #{dog_id} は存在しません")
        end
      end
    end
  end
end
