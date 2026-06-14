# frozen_string_literal: true

module Kennel
  module Domain
    module Medical
      module ConditionCatalog
        DEFINITIONS = {
          kennel_cough:      { name: 'ケンネルコフ',   chronic: false },
          hip_dysplasia:     { name: '股関節形成不全', chronic: true },
          patellar_luxation: { name: '膝蓋骨脱臼',     chronic: true },
          dental_disease:    { name: '歯周病',         chronic: true },
          atopy:             { name: 'アトピー性皮膚炎', chronic: true }
        }.freeze

        module_function

        def fetch(key)
          attributes = DEFINITIONS.fetch(key) { raise ArgumentError, "未知の病気です: #{key.inspect}" }
          Condition.new(key: key, **attributes)
        end
      end
    end
  end
end
