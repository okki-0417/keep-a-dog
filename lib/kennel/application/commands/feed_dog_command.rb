# frozen_string_literal: true

module Kennel
  module Application
    module Commands
      # gulped: 一気食い。深胸の犬種では胃捻転(GDV)の急性リスクになる。
      FeedDogCommand = Data.define(:dog_id, :satiety, :gulped)
    end
  end
end
