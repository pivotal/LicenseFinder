require 'spec_helper'

module LicenseFinder
  describe License do
    describe ".find_by_name" do
      it "should find a registered license" do
        License.find_by_name("Apache2").should be_a License
      end
    end

    describe ".find_by_text" do
      it "should find a registered license" do
        License.find_by_text('This gem is released under the MIT license').should be_a License
      end
    end

    def make_license(settings = {})
      described_class.new({
        short_name: "Default Short Name",
        url: "http://example.com/license",
        matcher: License::Matcher.from_text('Default Matcher')
      }.merge(settings))
    end

    it "should match on short_name" do
      make_license(short_name: "Foo").should be_matches_name "Foo"
    end

    it "should match on pretty name" do
      make_license(pretty_name: "Foo").should be_matches_name "Foo"
    end

    it "should match on alternative names" do
      license = make_license(other_names: ["Foo", "Bar"])
      license.should be_matches_name "Foo"
      license.should be_matches_name "Bar"
    end

    it "should match on text" do
      license = make_license(matcher: License::Matcher.new(/The license text/))
      license.should be_matches_text "The license text"
      license.should_not be_matches_text "Some other text"
    end

    it "should default pretty_name to short_name" do
      make_license.pretty_name.should == "Default Short Name"
    end

    it "should default other_names to none" do
      make_license.other_names.should be_empty
    end
  end
end
