require "spec_helper"

module LicenseFinder
  describe LicenseUrl do
    describe ".find_by_name" do
      subject { LicenseUrl }

      describe "when found" do
        before do
          License.stub(:find_by_name).with("Foo").
            and_return(double(:foo_license, url: "http://foo.license.com"))
        end

        specify { subject.find_by_name("Foo").should == "http://foo.license.com" }
      end

      describe "when not found" do
        before do
          License.stub(:find_by_name).with("").
            and_return(nil)
        end

        specify { subject.find_by_name(nil).should be_nil }
        specify { subject.find_by_name("").should be_nil }
      end
    end
  end
end
