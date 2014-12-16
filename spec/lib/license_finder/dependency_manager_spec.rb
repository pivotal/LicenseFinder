require 'spec_helper'

module LicenseFinder
  describe DependencyManager do
    let(:config) { Configuration.new('whitelist' => ['MIT', 'other']) }
    let(:decisions) do
      result = Decisions.new
      allow(result).to receive(:save!) { true }
      result
    end
    let(:dependency_manager) { described_class.new(decisions: decisions) }

    before do
      allow(LicenseFinder).to receive(:config).and_return config
      allow(Reporter).to receive(:write_reports)
    end

    describe ".manually_add" do
      it "should add decisions" do
        dependency_manager.manually_add("MIT", "js_dep", "0.0.0")
        decisions = dependency_manager.decisions
        expect(decisions.packages).to eq Set.new([ManualPackage.new("js_dep", "0.0.0")])
        expect(decisions.license_of("js_dep")).to eq License.find_by_name("MIT")
      end
    end

    describe ".manually_remove" do
      context "with a previous decision to manually add a dependency" do
        let(:decisions) do
          result = Decisions.new.add_package("a manually managed dep", nil)
          allow(result).to receive(:save!) { true }
          result
        end

        it "should add decisions" do
          dependency_manager.manually_add("GPL", "a manually managed dep", nil)
          dependency_manager.manually_remove("a manually managed dep")
          decisions = dependency_manager.decisions
          expect(decisions.packages).to be_empty
        end
      end
    end

    describe ".approve!" do
      it "should add decisions" do
        dependency_manager.manually_add("MIT", "current dependency", nil)
        dependency_manager.approve!("current dependency")
        decisions = dependency_manager.decisions
        expect(decisions).to be_approved("current dependency")
      end
    end

    describe ".license!" do
      let(:dependency) { double(:dependency) }

      it "should add decisions" do
        dependency_manager.license!("dependency", "MIT")
        decisions = dependency_manager.decisions
        expect(decisions.license_of("dependency")).to eq License.find_by_name("MIT")
      end
    end

    describe ".acknowledged" do
      it "combines manual and system packages" do
        decisions = Decisions.new.add_package("manual", nil)
        dependency_manager = described_class.new(decisions: decisions)
        allow(dependency_manager).to receive(:current_packages) { [ManualPackage.new("system", nil)] }
        expect(dependency_manager.acknowledged.map(&:name)).to match_array ["manual", "system"]
      end

      it "applies decided licenses" do
        decisions = Decisions.new.
          add_package("manual", nil).
          license("manual", "MIT")
        dependency_manager = described_class.new(decisions: decisions)
        allow(dependency_manager).to receive(:current_packages) { [] }
        expect(dependency_manager.acknowledged.last.licenses).to eq Set.new([License.find_by_name("MIT")])
      end

      it "ignores specific packages" do
        decisions = Decisions.new.
          add_package("manual", nil).
          ignore("manual")
        dependency_manager = described_class.new(decisions: decisions)
        allow(dependency_manager).to receive(:current_packages) { [] }
        expect(dependency_manager.acknowledged).to be_empty
      end

      it "ignores packages in certain groups" do
        decisions = Decisions.new.
          ignore_group("development")
        dependency_manager = described_class.new(decisions: decisions)
        dev_dep = ManualPackage.new("dep", nil)
        allow(dev_dep).to receive(:groups) { ["development"] }
        allow(dependency_manager).to receive(:current_packages) { [dev_dep] }
        expect(dependency_manager.acknowledged).to be_empty
      end

      it "adds manual approvals to packages" do
        decisions = Decisions.new.
          add_package("manual", nil).
          approve("manual", who: "Approver", why: "Because")
        dependency_manager = described_class.new(decisions: decisions)
        allow(dependency_manager).to receive(:current_packages) { [] }
        dep = dependency_manager.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_approved_manually
        expect(dep.manual_approval.approver).to eq "Approver"
        expect(dep.manual_approval.notes).to eq "Because"
      end

      it "adds whitelist approvals to packages" do
        decisions = Decisions.new.
          add_package("manual", nil).
          license("manual", "MIT").
          whitelist("MIT")
        dependency_manager = described_class.new(decisions: decisions)
        allow(dependency_manager).to receive(:current_packages) { [] }
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
        dependency_manager = described_class.new(decisions: decisions)
        allow(dependency_manager).to receive(:current_packages) { [grandparent, parent, child] }
        expect(dependency_manager.acknowledged.map(&:parents)).to eq([
          [].to_set,
          [grandparent].to_set,
          [parent].to_set
        ])
      end
    end
  end
end
