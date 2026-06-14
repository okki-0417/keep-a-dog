# frozen_string_literal: true

module Kennel
  module Domain
    module Senses
      VISIBLE_COLORS = %i[blue yellow].freeze
      MIN_HEARING_HZ = 67
      MAX_HEARING_HZ = 45_000
      SMELL_SENSITIVITY_FACTOR = 100_000

      module_function

      def color_vision
        :dichromatic
      end

      def sees_color?(color)
        VISIBLE_COLORS.include?(color)
      end

      def hears_frequency?(hz)
        (MIN_HEARING_HZ..MAX_HEARING_HZ).cover?(hz)
      end

      def smell_sensitivity_factor
        SMELL_SENSITIVITY_FACTOR
      end
    end
  end
end
