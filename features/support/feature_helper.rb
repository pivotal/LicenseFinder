# These are integration tests, so reaching directly into LicenseFinder is forbidden
# DO NOT:
# require 'rubygems'
# require 'bundler/setup'
# require 'license_finder'


RSpec.configure do |rspec|
  rspec.default_formatter = 'doc'
end
