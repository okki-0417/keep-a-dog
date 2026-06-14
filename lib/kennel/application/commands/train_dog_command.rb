# frozen_string_literal: true

module Kennel
  module Application
    module Commands
      TrainDogCommand = Data.define(:dog_id, :cue, :context)
    end
  end
end
