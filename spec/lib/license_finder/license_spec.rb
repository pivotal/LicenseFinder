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

    describe ".find_by_text" do
      before do
        LicenseFinder::License::MIT.stub(:new).with('a known license').and_return(double('MIT license', :matches? => true))
      end

      it "should match" do
        License.find_by_text('a known license').should == LicenseFinder::License::MIT
      end
    end
  end
end
