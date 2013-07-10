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
        let(:whitelist) { ["MIT", "other_license"] }

        it "does not create a duplicate entry" do
          config.should_not_receive(:save_to_yaml)

          described_class.add_license("MIT")
        end
      end

      describe "when the license is not in the whitelist" do
        let(:whitelist) { [] }

        it "adds the license to the whitelist" do
          config.should_receive(:save_to_yaml)

          described_class.add_license("MIT")

          config.whitelist.should include("MIT")
        end
      end
    end

    describe ".remove_license" do
      describe "when the license is not in the whitelist" do
        let(:whitelist) { [] }

        it "does not call save_to_yaml on config" do
          config.should_not_receive(:save_to_yaml)

          described_class.remove_license("MIT")
        end
      end

      describe "when the license is whitelisted" do
        let(:whitelist) { ["MIT", "other_license"] }

        it "removes the license from the whitelist" do
          config.should_receive(:save_to_yaml)

          described_class.remove_license("MIT")

          config.whitelist.should_not include("MIT")
        end
      end
    end
  end
end
