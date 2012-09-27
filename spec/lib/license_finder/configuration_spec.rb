require "spec_helper"

describe LicenseFinder::Configuration do
  it_behaves_like "a persistable configuration"

  describe "whitelisted?" do
    let(:config) { LicenseFinder::Configuration.new }

    context "canonical name whitelisted" do
      before { config.whitelist = [LicenseFinder::License::Apache2.names[rand(0...LicenseFinder::License::Apache2.names.count)]]}

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
end
