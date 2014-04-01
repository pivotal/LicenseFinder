require "spec_helper"

module LicenseFinder
  describe LicenseUrl do
    describe ".find_by_name" do
      subject { LicenseUrl }

      before do
        License.stub(:find_by_name).with("Foo").
          and_return(double(:foo_license, url: "http://foo.license.com"))
      end

      specify { subject.find_by_name("Foo").should == "http://foo.license.com" }
    end
  end
end
