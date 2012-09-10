require 'rubygems'
require 'bundler/setup'
require 'pry'

require 'license_finder'

require 'rspec'

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |file|
  require file
end

RSpec.configure do |config|
  config.mock_with :rr
end

