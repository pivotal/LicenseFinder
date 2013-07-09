require 'rubygems'
require 'bundler/setup'

require 'license_finder'
require 'rspec'

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |file|
  require file
end

RSpec.configure do |config|
  config.mock_with :rspec
end

require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, except: [:schema_migrations])
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
