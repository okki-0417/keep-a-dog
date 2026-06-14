# frozen_string_literal: true

module Kennel
  module Infrastructure
    module Persistence
      class InMemoryDogRepository
        include Domain::Repositories::DogRepository

        def initialize
          @store = {}
        end

        def find(id)
          @store[id]
        end

        def save(dog)
          @store[dog.id] = dog
          dog
        end

        def delete(id)
          @store.delete(id)
        end

        def all
          @store.values
        end
      end
    end
  end
end
