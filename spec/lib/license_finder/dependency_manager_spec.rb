require 'spec_helper'

module LicenseFinder
  describe DependencyManager do
    let(:config) { Configuration.new('whitelist' => ['MIT', 'other']) }

    before do
      LicenseFinder.stub(:config).and_return config
      Reporter.stub(:write_reports)
    end

    describe "#sync" do
      let(:gem1) { double(:package) }
      let(:gem2) { double(:package) }

      it "destroys every dependency except for the ones Bundler reports as 'current' or are marked as 'added_manually'" do
        cur1 = Dependency.create(name: "current dependency 1")
        cur2 = Dependency.create(name: "current dependency 2")
        man1 = Dependency.create(name: "manual dependency", added_manually: true)
        Dependency.create(name: "old dependency 1")
        Dependency.create(name: "old dependency 2")

        current_packages = [gem1, gem2]
        Bundler.stub(:current_packages) { current_packages }
        PackageSaver.should_receive(:save_all).with(current_packages).and_return([cur1, cur2])

        described_class.sync_with_package_managers
        Dependency.all.map(&:name).should =~ [cur1, cur2, man1].map(&:name)
      end
    end

    describe ".manually_add" do
      it "should add a Dependency" do
        expect do
          described_class.manually_add("MIT", "js_dep", "0.0.0")
        end.to change(Dependency, :count).by(1)
      end

      it "should mark the dependency as manual" do
        described_class.manually_add("MIT", "js_dep", "0.0.0")
          .should be_added_manually
      end

      it "should set the appropriate values" do
        dep = described_class.manually_add("GPL", "js_dep", "0.0.0")
        dep.name.should == "js_dep"
        dep.version.should == "0.0.0"
        dep.license.name.should == "GPL"
        dep.should_not be_approved
      end

      it "should complain if the dependency already exists" do
        Dependency.create(name: "current dependency 1")
        expect { described_class.manually_add("GPL", "current dependency 1", "0.0.0") }
          .to raise_error(Error)
      end
    end

    describe ".manually_remove" do
      it "should remove a manually managed Dependency" do
        described_class.manually_add("GPL", "a manually managed dep", nil)
        expect do
          described_class.manually_remove("a manually managed dep")
        end.to change(Dependency, :count).by(-1)
      end

      it "should not remove a bundler Dependency" do
        Dependency.create(name: "a bundler dep")
        expect do
          expect do
            described_class.manually_remove("a bundler dep")
          end.to raise_error(Error)
        end.to_not change(Dependency, :count)
      end
    end

    describe ".approve!" do
      it "approves the dependency" do
        dep = Dependency.named("current dependency")
        dep.license = License.find_by_name('not approved')
        dep.save
        dep.reload.should_not be_approved
        described_class.approve!("current dependency")
        dep.reload.should be_approved
      end

      it "optionally adds approver and approval notes" do
        dep = Dependency.named("current dependency")
        described_class.approve!("current dependency", "Julian", "We really need this")
        approval = dep.reload.manual_approval
        approval.approver.should eq "Julian"
        approval.notes.should eq "We really need this"
      end

      it "should raise an error if it can't find the dependency" do
        expect { described_class.approve!("non-existent dependency") }
          .to raise_error(Error)
      end
    end

    describe ".license!" do
      let(:dependency) { double(:dependency) }

      it "adds a license for the dependency" do
        DependencyManager.stub(:find_by_name).with("dependency").and_return(dependency)
        dependency.should_receive(:set_license_manually!).with(License.find_by_name "MIT")
        described_class.license!("dependency", "MIT")
      end

      it "should raise an error if it can't find the dependency" do
        expect { described_class.license!("non-existent dependency", "a license") }
          .to raise_error(Error)
      end
    end

    describe ".modifying" do
      let(:file_exists) { double(:file, :exist? => true) }
      let(:file_does_not_exist) { double(:file, :exist? => false) }

      context "when the database doesn't exist" do
        before do
          config.artifacts.stub(:database_file).and_return(file_does_not_exist)
        end

        it "writes reports" do
          Reporter.should_receive(:write_reports)
          DependencyManager.modifying {}
        end
      end

      context "when the database exists" do
        before do
          config.artifacts.stub(:database_file).and_return(file_exists)
        end

        context "when the database has changed" do
          before do
            i = 0
            Digest::SHA2.stub_chain(:file, :hexdigest) { i += 1 }
          end

          it "writes reports" do
            Reporter.should_receive(:write_reports)
            DependencyManager.modifying {}
          end
        end

        context "when the database has not changed" do
          before do
            Digest::SHA2.stub_chain(:file, :hexdigest) { 5 }
          end

          context "when the reports exist" do
            before do
              config.artifacts.stub(:html_file).and_return(file_exists)
            end

            it "does not write reports" do
              Reporter.should_not_receive(:write_reports)
              DependencyManager.modifying {}
            end
          end

          context "when the reports do not exist" do
            before do
              config.artifacts.stub(:html_file).and_return(file_does_not_exist)
            end

            it "writes reports" do
              Reporter.should_receive(:write_reports)
              DependencyManager.modifying {}
            end
          end
        end
      end
    end
  end
end
