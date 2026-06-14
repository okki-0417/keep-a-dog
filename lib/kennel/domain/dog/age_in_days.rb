# frozen_string_literal: true

module Kennel
  module Domain
    class Dog
      class AgeInDays
        attr_reader :days

        def initialize(days)
          raise ArgumentError, '日齢は0以上の整数でなければなりません' unless days.is_a?(Integer) && !days.negative?

          @days = days
        end

        def advanced_by(more)
          raise ArgumentError, '加齢は逆行しません' if more.negative?

          self.class.new(@days + more)
        end
      end
    end
  end
end
