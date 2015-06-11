require 'spec_helper'

module LicenseFinder
  describe DecisionApplier do
    describe "#acknowledged" do
      it "combines manual and system packages" do
        decision_applier = described_class.new(
          decisions: Decisions.new.add_package("manual", nil),
          packages: [Package.new("system")]
        )
        expect(decision_applier.acknowledged.map(&:name)).to match_array ["manual", "system"]
      end

      it "applies decided licenses" do
        decisions = Decisions.new
          .add_package("manual", nil)
          .license("manual", "MIT")
        decision_applier = described_class.new(decisions: decisions, packages: [])
        expect(decision_applier.acknowledged.last.licenses).to eq Set.new([License.find_by_name("MIT")])
      end

      it "ignores specific packages" do
        decisions = Decisions.new
          .add_package("manual", nil)
          .ignore("manual")
        decision_applier = described_class.new(decisions: decisions, packages: [])
        expect(decision_applier.acknowledged).to be_empty
      end

      it "ignores packages in certain groups" do
        decisions = Decisions.new
          .ignore_group("development")
        dev_dep = Package.new("dep", nil, groups: ["development"])
        decision_applier = described_class.new(
          decisions: decisions,
          packages: [dev_dep]
        )
        expect(decision_applier.acknowledged).to be_empty
      end

      it "adds manual approvals to packages" do
        decisions = Decisions.new
          .add_package("manual", nil)
          .approve("manual", who: "Approver", why: "Because")
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_approved_manually
        expect(dep.manual_approval.who).to eq "Approver"
        expect(dep.manual_approval.why).to eq "Because"
      end

      it "adds whitelist approvals to packages" do
        decisions = Decisions.new
          .add_package("manual", nil)
          .license("manual", "MIT")
          .whitelist("MIT")
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_whitelisted
      end
    end

    describe "#unapproved" do
      it "returns all acknowledged packages that are not approved" do
        manual_package = double(:manual, name: 'manual', approved?: true )
        whitelist_package = double(:whitelist, name: 'whitelist', approved?: true)
        bad_package = double(:not_approved, name: 'not_approved', approved?: false)
        decisions = double(:decisions)

        decision_applier = described_class.new(decisions: decisions, packages: [])
        allow(decision_applier).to receive(:acknowledged).and_return([manual_package, whitelist_package, bad_package])
        expect(decision_applier.unapproved).to include(bad_package)
      end
    end
  end
end
