require "spec_helper"

module LicenseFinder
  describe Configuration do
    let(:config) { described_class.new }

    let(:klass) { described_class }

    let(:attributes) do
      {
        "whitelist" => ["FooLicense", "BarLicense"],
        "ignore_groups" => [:test, :development]
      }
    end

    describe '.new' do
      subject { klass.new(attributes) }

      context "with known attributes" do
        it "should set the all of the attributes on the instance" do
          attributes.each do |key, value|
            subject.send("#{key}").should == value
          end
        end
      end
    end

    describe "#whitelist" do
      it "should default to an empty array" do
        klass.new.whitelist.should == []
      end
    end

    describe "whitelisted?" do
      context "canonical name whitelisted" do
        before { config.whitelist = [License::Apache2.names[rand(License::Apache2.names.count)]]}

        let(:possible_license_names) { License::Apache2.names }

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
end
