# frozen_string_literal: true

module Kennel
  module Application
    module Commands
      VaccinateDogCommand = Data.define(:dog_id, :disease)
    end
  end
end
