require 'spec_helper'

module LicenseFinder
  describe PackageManager do
    describe "#current_packages_with_relations" do
      it "sets packages' parents" do
        grandparent = Package.new("grandparent", nil, children: ["parent"])
        parent      = Package.new("parent",      nil, children: ["child"])
        child       = Package.new("child")

        pm = described_class.new
        allow(pm).to receive(:current_packages) { [grandparent, parent, child] }

        expect(pm.current_packages_with_relations.map(&:parents)).to eq([
          [].to_set,
          ["grandparent"].to_set,
          ["parent"].to_set
        ])
      end
    end

    describe "#package_management_command" do
      it "defaults to nil" do
        expect(LicenseFinder::PackageManager.package_management_command).to be_nil
      end
    end

    describe ".installed?" do
      context "package_management_command is nil" do
        before do
          allow(LicenseFinder::PackageManager).to receive(:package_management_command).and_return(nil)
        end

        it "returns true" do
          expect(LicenseFinder::PackageManager.installed?).to be_truthy
        end
      end

      context "package_management_command exists" do
        before do
          allow(LicenseFinder::PackageManager).to receive(:package_management_command).and_return("foobar")
          allow(LicenseFinder::PackageManager).to receive(:command_exists?).with("foobar").and_return(true)
        end

        it "returns true" do
          expect(LicenseFinder::PackageManager.installed?).to be_truthy
        end
      end

      context "package_management_command does not exist" do
        before do
          allow(LicenseFinder::PackageManager).to receive(:package_management_command).and_return("foobar")
          allow(LicenseFinder::PackageManager).to receive(:command_exists?).with("foobar").and_return(false)
        end

        it "returns false" do
          expect(LicenseFinder::PackageManager.installed?).to be_falsey
        end
      end
    end
  end
end
