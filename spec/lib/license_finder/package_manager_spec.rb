require 'spec_helper'

module LicenseFinder
  describe PackageManager do
    describe "#current_packages_with_relations" do
      it "sets packages' parents" do
        grandparent = ManualPackage.new("grandparent", nil)
        parent = ManualPackage.new("parent", nil)
        child = ManualPackage.new("child", nil)
        allow(grandparent).to receive(:children) { ["parent"] }
        allow(parent).to receive(:children) { ["child"] }

        pm = described_class.new
        allow(pm).to receive(:current_packages) { [grandparent, parent, child] }

        expect(pm.current_packages_with_relations.map(&:parents)).to eq([
          [].to_set,
          ["grandparent"].to_set,
          ["parent"].to_set
        ])
      end
    end
  end
end
