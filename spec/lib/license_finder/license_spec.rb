require 'spec_helper'

describe LicenseFinder::License::Base do
  describe ".names" do
    subject do
      Class.new(LicenseFinder::License::Base) do
        def self.demodulized_name; "FooLicense"; end
        self.alternative_names = ["foo license"]
      end.names
    end

    it { should =~ ["FooLicense", "foo license"] }
  end
end
