# frozen_string_literal: true

module Kennel
  module Application
    module Commands
      AdoptDogCommand = Data.define(:breed_key, :age_in_days)
    end
  end
end
