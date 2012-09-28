require "spec_helper"

describe LicenseFinder::Configuration do
  it_behaves_like "a persistable configuration"

  let(:config) { LicenseFinder::Configuration.new }

  describe "whitelisted?" do
    context "canonical name whitelisted" do
      before { config.whitelist = [LicenseFinder::License::Apache2.names[rand(LicenseFinder::License::Apache2.names.count)]]}

      let(:possible_license_names) { LicenseFinder::License::Apache2.names }

      it "should return true if if the license is the canonical name, pretty name, or alternative name of the license" do
        possible_license_names.each do |name|
          config.whitelisted?(name).should be_true, "expected #{name} to be whitelisted, but wasn't."
        end
      end

      it "should be case-insensitive" do
        possible_license_names.map(&:downcase).each do |name|
          config.whitelisted?(name).should be_true, "expected #{name} to be whitelisted, but wasn't"
        end
      end
    end
  end

  describe "#ignore_groups" do
    it "should default to an empty array" do
      config.ignore_groups.should == []
    end

    it "should always return symbolized versions of the ignore groups" do
      config.ignore_groups = %w[test development]
      config.ignore_groups.should == [:test, :development]
    end
  end
end
