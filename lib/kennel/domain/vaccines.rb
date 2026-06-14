# frozen_string_literal: true

module Kennel
  module Domain
    module Vaccines
      LEGALLY_REQUIRED = %i[rabies].freeze

      module_function

      def legally_required?(disease)
        LEGALLY_REQUIRED.include?(disease)
      end
    end
  end
end
