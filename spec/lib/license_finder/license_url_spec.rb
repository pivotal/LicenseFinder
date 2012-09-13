require "spec_helper"

class FooLicense < LicenseFinder::License::Base
  self.alternative_names = ["the foo license"]
  self.license_url = "http://foo.license.com"
end

describe LicenseFinder::LicenseUrl do
  describe ".find_by_name" do
    subject { LicenseFinder::LicenseUrl }

    specify { subject.find_by_name("FooLicense").should      == "http://foo.license.com" }
    specify { subject.find_by_name("fOolICENse").should      == "http://foo.license.com" }
    specify { subject.find_by_name("the foo license").should == "http://foo.license.com" }

    specify { subject.find_by_name(nil).should be_nil }
    specify { subject.find_by_name("").should be_nil }
    specify { subject.find_by_name("unknown license").should be_nil }
  end
end
