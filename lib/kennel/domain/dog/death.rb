# frozen_string_literal: true

module Kennel
  module Domain
    class Dog
      class Death
        LABELS = { old_age: '老衰' }.freeze

        attr_reader :cause

        def initialize(cause:)
          raise ArgumentError, "未知の死因です: #{cause.inspect}" unless LABELS.key?(cause)

          @cause = cause
        end

        def label
          LABELS.fetch(@cause)
        end
      end
    end
  end
end
