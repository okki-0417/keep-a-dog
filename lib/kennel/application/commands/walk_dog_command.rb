# frozen_string_literal: true

module Kennel
  module Application
    module Commands
      WalkDogCommand = Data.define(:dog_id, :minutes)
    end
  end
end
