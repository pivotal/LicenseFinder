# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'license_finder'

require 'rspec'
require 'webmock/rspec'
require 'rspec/its'

require 'pry'

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].sort.each do |file|
  require file
end

RSpec.configure do |config|
  config.mock_with :rspec
end

RSpec.configure do |config|
  config.include SharedDefinitions

  config.after(:suite) do
    ['./doc'].each do |tmp_dir|
      tmp_dir = Pathname(tmp_dir)
      tmp_dir.rmtree if tmp_dir.directory?
    end
  end

  config.include LicenseFinder::TestFixtures
end
