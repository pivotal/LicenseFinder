require 'rubygems'
require 'bundler/setup'

require 'license_finder'

require 'rspec'
RSpec.configure do |config|
  config.mock_with :rr
end

