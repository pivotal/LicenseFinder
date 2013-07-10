require "spec_helper"

module LicenseFinder
  describe WhitelistManager do
    let(:config) { Configuration.new }

    before do
      LicenseFinder.stub(:config).and_return config
      config.whitelist = whitelist
    end

    describe ".add_license" do
      describe "when the license is already whitelisted" do
        let(:whitelist) { ["test", "other_license"] }

        it "does not create a duplicate entry" do
          config.should_not_receive(:save_to_yaml)

          described_class.add_license("test")
        end
      end

      describe "when the license is not in the whitelist" do
        let(:whitelist) { [] }

        it "adds the license to the whitelist" do
          config.should_receive(:save_to_yaml)

          described_class.add_license("test")

          config.whitelist.should include("test")
        end
      end
    end
  end
end
