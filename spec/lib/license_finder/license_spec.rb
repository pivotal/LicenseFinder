require 'spec_helper'

module LicenseFinder
  describe License do
    describe ".find_by_name" do
      it "should match on demodulized names" do
        License.find_by_name("Apache2").should == License::Apache2
      end

      it "should match on pretty names" do
        License.find_by_name("Apache 2.0").should == License::Apache2
      end

      it "should match on alternative names" do
        License.find_by_name("Apache Software License").should == License::Apache2
      end

      it "should ignore case" do
        License.find_by_name("apache2").should == License::Apache2
      end

      it "should return nil if no match" do
        License.find_by_name(:unknown).should be_nil
      end
    end

    describe ".find_by_text" do
      before do
        LicenseFinder::License::MIT.stub(:new).with('a known license').
          and_return(double('MIT license', :matches? => true))
      end

      it "should match" do
        License.find_by_text('a known license').should == LicenseFinder::License::MIT
      end
    end
  end
end
