require 'rubygems'
require 'bundler/setup'

require 'license_finder'

require './features/support/testing_dsl'

RSpec.configure do |rspec|
  rspec.default_formatter = 'doc'
end
