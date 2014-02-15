require 'spec_helper'

describe LicenseFinder do
  describe ".config" do
    it "should load the configuration exactly once" do
      LicenseFinder.instance_variable_set(:@config, nil)

      LicenseFinder::Configuration.should_receive(:ensure_default).once.and_return(double(:config))

      LicenseFinder.config
      LicenseFinder.config

      LicenseFinder.instance_variable_set(:@config, nil)
    end
  end
end
