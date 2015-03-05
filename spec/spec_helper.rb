require 'rubygems'
require 'bundler/setup'
require 'license_finder'

require 'pry'
require 'rspec'
require 'webmock/rspec'
require 'rspec/its'

ENV['test_run'] = true.to_s

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |file|
  require file
end

RSpec.configure do |config|
  config.mock_with :rspec
end

RSpec.configure do |config|
  config.after(:suite) do
    ["./doc", "./elsewhere", "./test path", "./config"].each do |tmp_dir|
      Pathname(tmp_dir).rmtree
    end
  end

  config.include LicenseFinder::TestFixtures
end
