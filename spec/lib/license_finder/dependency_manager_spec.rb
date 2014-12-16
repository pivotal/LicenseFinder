require 'spec_helper'

module LicenseFinder
  describe DependencyManager do
    describe ".acknowledged" do
      it "combines manual and system packages" do
        decisions = Decisions.new.add_package("manual", nil)
        dependency_manager = described_class.new(
          decisions: decisions,
          packages: [ManualPackage.new("system", nil)]
        )
        expect(dependency_manager.acknowledged.map(&:name)).to match_array ["manual", "system"]
      end

      it "applies decided licenses" do
        decisions = Decisions.new.
          add_package("manual", nil).
          license("manual", "MIT")
        dependency_manager = described_class.new(decisions: decisions, packages: [])
        expect(dependency_manager.acknowledged.last.licenses).to eq Set.new([License.find_by_name("MIT")])
      end

      it "ignores specific packages" do
        decisions = Decisions.new.
          add_package("manual", nil).
          ignore("manual")
        dependency_manager = described_class.new(decisions: decisions, packages: [])
        expect(dependency_manager.acknowledged).to be_empty
      end

      it "ignores packages in certain groups" do
        decisions = Decisions.new.
          ignore_group("development")
        dev_dep = ManualPackage.new("dep", nil)
        allow(dev_dep).to receive(:groups) { ["development"] }
        dependency_manager = described_class.new(
          decisions: decisions,
          packages: [dev_dep]
        )
        expect(dependency_manager.acknowledged).to be_empty
      end

      it "adds manual approvals to packages" do
        decisions = Decisions.new.
          add_package("manual", nil).
          approve("manual", who: "Approver", why: "Because")
        dependency_manager = described_class.new(decisions: decisions, packages: [])
        dep = dependency_manager.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_approved_manually
        expect(dep.manual_approval.who).to eq "Approver"
        expect(dep.manual_approval.why).to eq "Because"
      end

      it "adds whitelist approvals to packages" do
        decisions = Decisions.new.
          add_package("manual", nil).
          license("manual", "MIT").
          whitelist("MIT")
        dependency_manager = described_class.new(decisions: decisions, packages: [])
        dep = dependency_manager.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_whitelisted
      end

      it "sets packages parents" do
        decisions = Decisions.new
        grandparent = ManualPackage.new("grandparent", nil)
        parent = ManualPackage.new("parent", nil)
        child = ManualPackage.new("child", nil)
        allow(grandparent).to receive(:children) { ["parent"] }
        allow(parent).to receive(:children) { ["child"] }
        dependency_manager = described_class.new(
          decisions: decisions,
          packages: [grandparent, parent, child]
        )
        expect(dependency_manager.acknowledged.map(&:parents)).to eq([
          [].to_set,
          [grandparent].to_set,
          [parent].to_set
        ])
      end
    end
  end
end
