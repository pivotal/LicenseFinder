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

    describe "#sync" do
      let(:gem1) { ManualPackage.new("current dependency 1") }
      let(:gem2) { ManualPackage.new("current dependency 2") }
      let!(:bundler) { Bundler.new }

      before { allow(Bundler).to receive(:new) { bundler } }

      it "destroys every dependency except for the ones Bundler reports as 'current' or are marked as 'added_manually'" do
        cur1 = Dependency.create(name: "current dependency 1")
        cur2 = Dependency.create(name: "current dependency 2")
        man1 = Dependency.create(name: "manual dependency", added_manually: true)
        Dependency.create(name: "old dependency 1")
        Dependency.create(name: "old dependency 2")

        current_packages = [gem1, gem2]
        allow(bundler).to receive(:current_packages) { current_packages }
        expect(PackageSaver).to receive(:save_all).with(current_packages).and_return([cur1, cur2])

        dependency_manager.sync_with_package_managers
        expect(Dependency.all.map(&:name)).to match_array([cur1, cur2, man1].map(&:name))
      end
    end

    describe ".manually_add" do
      it "should add a Dependency" do
        expect do
          dependency_manager.manually_add("MIT", "js_dep", "0.0.0")
        end.to change(Dependency, :count).by(1)
      end

      it "should mark the dependency as manual" do
        expect(dependency_manager.manually_add("MIT", "js_dep", "0.0.0"))
          .to be_added_manually
      end

      it "should set the appropriate values" do
        dep = dependency_manager.manually_add("GPL", "js_dep", "0.0.0")
        expect(dep.name).to eq("js_dep")
        expect(dep.version).to eq("0.0.0")
        expect(dep.licenses.first.name).to eq("GPL")
        expect(dep).not_to be_approved
      end

      it "should complain if the dependency already exists" do
        Dependency.create(name: "current dependency 1")
        expect { dependency_manager.manually_add("GPL", "current dependency 1", "0.0.0") }
          .to raise_error(Error)
      end

      it "should add decisions" do
        dependency_manager.manually_add("MIT", "js_dep", "0.0.0")
        decisions = dependency_manager.decisions
        expect(decisions.packages).to eq Set.new([ManualPackage.new("js_dep", "0.0.0")])
        expect(decisions.license_of("js_dep")).to eq License.find_by_name("MIT")
      end
    end

    describe ".manually_remove" do
      it "should remove a manually managed Dependency" do
        dependency_manager.manually_add("GPL", "a manually managed dep", nil)
        expect do
          dependency_manager.manually_remove("a manually managed dep")
        end.to change(Dependency, :count).by(-1)
      end

      it "should not remove a bundler Dependency" do
        Dependency.create(name: "a bundler dep")
        expect do
          expect do
            dependency_manager.manually_remove("a bundler dep")
          end.to raise_error(Error)
        end.to_not change(Dependency, :count)
      end

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
      it "approves the dependency" do
        dep = Dependency.named("current dependency")
        dep.licenses = [License.find_by_name('not approved')].to_set
        dep.save
        expect(dep.reload).not_to be_approved
        dependency_manager.approve!("current dependency")
        expect(dep.reload).to be_approved
      end

      it "optionally adds approver and approval notes" do
        dep = Dependency.named("current dependency")
        dependency_manager.approve!("current dependency", "Julian", "We really need this")
        approval = dep.reload.manual_approval
        expect(approval.approver).to eq "Julian"
        expect(approval.notes).to eq "We really need this"
      end

      it "should raise an error if it can't find the dependency" do
        expect { dependency_manager.approve!("non-existent dependency") }
          .to raise_error(Error)
      end

      it "should add decisions" do
        dep = Dependency.named("current dependency")
        dependency_manager.approve!("current dependency")
        decisions = dependency_manager.decisions
        expect(decisions).to be_approved("current dependency")
      end
    end

    describe ".license!" do
      let(:dependency) { double(:dependency) }

      it "adds a license for the dependency" do
        allow(dependency_manager).to receive(:find_by_name).with("dependency").and_return(dependency)
        expect(dependency).to receive(:set_license_manually!).with(License.find_by_name "MIT")
        dependency_manager.license!("dependency", "MIT")
      end

      it "should raise an error if it can't find the dependency" do
        expect { dependency_manager.license!("non-existent dependency", "a license") }
          .to raise_error(Error)
      end

      it "should add decisions" do
        dep = Dependency.named("dependency")
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

    describe ".modifying" do
      let(:file_exists) { double(:file, :exist? => true) }
      let(:file_does_not_exist) { double(:file, :exist? => false) }

      context "when the database doesn't exist" do
        before do
          allow(config.artifacts).to receive(:database_file).and_return(file_does_not_exist)
        end

        it "writes reports" do
          expect(Reporter).to receive(:write_reports)
          dependency_manager.modifying {}
        end
      end

      context "when the database exists" do
        before do
          allow(config.artifacts).to receive(:database_file).and_return(file_exists)
        end

        context "when the database has changed" do
          before do
            i = 0
            allow(Digest::SHA2).to receive_message_chain(:file, :hexdigest) { i += 1 }
          end

          it "writes reports" do
            expect(Reporter).to receive(:write_reports)
            dependency_manager.modifying {}
          end
        end

        context "when the database has not changed" do
          before do
            allow(Digest::SHA2).to receive_message_chain(:file, :hexdigest) { 5 }
            allow(config).to receive(:last_modified) { config_last_update }
            allow(config.artifacts).to receive(:last_refreshed) { artifacts_last_update }
          end

          context "and the reports do not exist" do
            before do
              allow(config.artifacts).to receive(:html_file).and_return(file_does_not_exist)
            end

            it "writes reports" do
              expect(Reporter).to receive(:write_reports)
              dependency_manager.modifying {}
            end
          end

          context "and the reports exist" do
            before do
              allow(config.artifacts).to receive(:html_file).and_return(file_exists)
            end

            context "and configs are newer than the reports" do
              let(:config_last_update) { 4 }
              let(:artifacts_last_update) { 1 }
              it "writes reports" do
                expect(Reporter).to receive(:write_reports)
                dependency_manager.modifying {}
              end
            end

            context "and configs are older than the reports" do
              let(:config_last_update) { 4 }
              let(:artifacts_last_update) { 6 }

              it "does not write reports" do
                expect(Reporter).not_to receive(:write_reports)
                dependency_manager.modifying {}
              end
            end
          end
        end
      end
    end
  end
end
