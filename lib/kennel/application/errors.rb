# frozen_string_literal: true

module Kennel
  module Application
    module Errors
      class ApplicationError < StandardError; end

      class DogNotFound < ApplicationError; end
    end
  end
end
