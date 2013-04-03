require 'spec_helper'

module LicenseFinder
  describe LicenseAlias do
    describe 'initializes' do
      it "delegates to LicenseUrl.find_by_name for the url" do
        LicenseUrl.stub(:find_by_name).with("MIT").and_return "http://license-url.com"
        license = described_class.new(name: 'MIT')
        license.url.should == "http://license-url.com"
      end
    end

    describe "#set_manually" do
      subject do
        described_class.create(name: 'Original')
      end

      it "modifies the license" do
        subject.set_manually('Updated')
        subject.reload.name.should == 'Updated'
      end

      it "marks the approval as manual" do
        subject.set_manually('Updated')
        subject.reload.manual.should be_true
      end
    end

    describe "#whitelisted?" do
      let(:config) { Configuration.new }

      before do
        LicenseFinder.stub(:config).and_return config
        config.whitelist = ["MIT", "other"]
      end

      it "should return true when the license is whitelisted" do
        described_class.new(name: 'MIT').should be_whitelisted
      end

      it "should return true when the license is an alternative name of a whitelisted license" do
        described_class.new(name: 'Expat').should be_whitelisted
      end

      it "should return true when the license has no matching license class, but is whitelisted anyways" do
        described_class.new(name: 'other').should be_whitelisted
      end

      it "should return false when the license is not whitelisted" do
        described_class.new(name: 'GPL').should_not be_whitelisted
      end
    end
  end
end
