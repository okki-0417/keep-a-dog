# frozen_string_literal: true

module Kennel
  module Domain
    module Repositories
      module DogRepository
        def find(_id)
          raise NotImplementedError, "#{self.class}#find を実装してください"
        end

        def save(_dog)
          raise NotImplementedError, "#{self.class}#save を実装してください"
        end

        def delete(_id)
          raise NotImplementedError, "#{self.class}#delete を実装してください"
        end
      end
    end
  end
end
