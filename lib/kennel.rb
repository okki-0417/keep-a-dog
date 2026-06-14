# frozen_string_literal: true

require 'zeitwerk'

module Kennel
  loader = Zeitwerk::Loader.for_gem
  loader.inflector.inflect('cli' => 'CLI')
  loader.setup
end
