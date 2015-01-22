require 'rubygems'
require 'bundler/setup'

require 'pry'
require 'license_finder'
require 'rspec'
require 'webmock/rspec'
require 'rspec/its'
require 'fileutils'

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
      FileUtils.rm_rf(tmp_dir)
    end
  end

  config.include LicenseFinder::TestFixtures
end
