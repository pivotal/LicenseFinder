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
        demodulized_name: "Default Demodulized Name",
        license_url: "http://example.com/license",
        matching_algorithm: License::TextMatcher.new('Default Matcher')
      }.merge(settings))
    end

    it "should match on demodulized_name" do
      make_license(demodulized_name: "Foo").should be_matches_name "Foo"
    end

    it "should match on pretty name" do
      make_license(pretty_name: "Foo").should be_matches_name "Foo"
    end

    it "should match on alternative names" do
      license = make_license(alternative_names: ["Foo", "Bar"])
      license.should be_matches_name "Foo"
      license.should be_matches_name "Bar"
    end

    it "should default pretty_name to demodulized_name" do
      make_license.pretty_name.should == "Default Demodulized Name"
    end

    it "should default alternative_names to none" do
      make_license.alternative_names.should be_empty
    end
  end
end
