require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  track_files 'lib/**/*.rb'
  add_filter '/spec/'
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'kennel'

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.default_formatter = 'doc'
end
