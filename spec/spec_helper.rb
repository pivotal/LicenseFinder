require 'rubygems'
require 'bundler/setup'

require 'pry'
require 'license_finder'
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
  config.around do |example|
    LicenseFinder::DB.transaction(rollback: :always) { example.run }
  end

  config.after(:suite) do
    ["./doc", "./elsewhere", "./test path", "./config"].each do |tmp_dir|
      FileUtils.rm_rf(tmp_dir)
    end
  end
end

module LicenseFinder
  shared_examples "it conforms to interface required by PackageSaver" do
    it { expect { subject.name }.to_not raise_error }
    it { expect { subject.version }.to_not raise_error }
    it { expect { subject.summary }.to_not raise_error }
    it { expect { subject.description }.to_not raise_error }
    it { expect { subject.homepage }.to_not raise_error }
    it { expect { subject.groups }.to_not raise_error }
    it { expect { subject.children }.to_not raise_error }
    it { expect { subject.licenses }.to_not raise_error }
  end
end
