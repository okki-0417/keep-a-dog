# frozen_string_literal: true

module Kennel
  module Domain
    module Medical
      class Condition
        attr_reader :key, :name

        def initialize(key:, name:, chronic:)
          @key = key
          @name = name
          @chronic = chronic
        end

        def chronic?
          @chronic
        end

        def acute?
          !@chronic
        end
      end
    end
  end
end
