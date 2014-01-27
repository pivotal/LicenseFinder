require 'rubygems'
require 'bundler/setup'

require 'pry'
require 'license_finder'
require 'rspec'
require 'webmock/rspec'

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |file|
  require file
end

RSpec.configure do |config|
  config.mock_with :rspec
end

RSpec.configure do |config|
  config.before { FileUtils.rm_f("config/license_finder.yml") }
  config.around do |example|
    LicenseFinder::DB.transaction(rollback: :always) { example.run }
  end
end
