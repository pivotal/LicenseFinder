require 'spec_helper'

class FooLicense < LicenseFinder::License::Base
  self.alternative_names = ["the foo license"]
  self.license_url = "http://foo.license.com"

  def self.pretty_name
    "Ye Ole Foo License"
  end
end

module LicenseFinder
  describe License do
    describe ".find_by_name" do
      it "should match on demodulized names" do
        License.find_by_name("FooLicense").should == FooLicense
      end

      it "should match on pretty names" do
        License.find_by_name("Ye Ole Foo License").should == FooLicense
      end

      it "should match on alternative names" do
        License.find_by_name("the foo license").should == FooLicense
      end

      it "should return nil if no match" do
        License.find_by_name(:unknown).should be_nil
      end
    end
  end
end

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
