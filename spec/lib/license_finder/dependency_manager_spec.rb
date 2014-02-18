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

      it "destroys every dependency except for the ones Bundler reports as 'current' or are marked as 'manual'" do
        cur1 = Dependency.create(name: "current dependency 1")
        cur2 = Dependency.create(name: "current dependency 2")
        man1 = Dependency.create(name: "manual dependency", manual: true)
        Dependency.create(name: "old dependency 1")
        Dependency.create(name: "old dependency 2")

        current_packages = [gem1, gem2]
        Bundler.stub(:current_packages) { current_packages }
        PackageSaver.should_receive(:save_all).with(current_packages).and_return([cur1, cur2])

        described_class.sync_with_package_managers
        Dependency.all.map(&:name).should =~ [cur1, cur2, man1].map(&:name)
      end
    end

    describe ".create_manually_managed" do
      it "should add a Dependency" do
        expect do
          described_class.create_manually_managed("MIT", "js_dep", "0.0.0")
        end.to change(Dependency, :count).by(1)
      end

      it "should mark the dependency as manual" do
        described_class.create_manually_managed("MIT", "js_dep", "0.0.0")
          .should be_manual
      end

      it "should set the appropriate values" do
        dep = described_class.create_manually_managed("GPL", "js_dep", "0.0.0")
        dep.name.should == "js_dep"
        dep.version.should == "0.0.0"
        dep.license.name.should == "GPL"
        dep.should_not be_approved
      end

      it "should complain if the dependency already exists" do
        Dependency.create(name: "current dependency 1")
        expect { described_class.create_manually_managed("GPL", "current dependency 1", "0.0.0") }
          .to raise_error(LicenseFinder::Error)
      end

      it "re-uses an existing, unassociated, license alias" do
        existing_license = LicenseAlias.named("existing license")

        dep = described_class.create_manually_managed("existing license", "js_dep", "0.0.0")
        dep.license.should == existing_license
      end
    end

    describe ".destroy_manually_managed" do
      it "should remove a manually managed Dependency" do
        described_class.create_manually_managed("GPL", "a manually managed dep", nil)
        expect do
          described_class.destroy_manually_managed("a manually managed dep")
        end.to change(Dependency, :count).by(-1)
      end

      it "should not remove a bundler Dependency" do
        Dependency.create(name: "a bundler dep")
        expect do
          expect do
            described_class.destroy_manually_managed("a bundler dep")
          end.to raise_error(LicenseFinder::Error)
        end.to_not change(Dependency, :count)
      end
    end

    describe ".approve!" do
      it "approves the dependency" do
        dep = Dependency.named("current dependency")
        dep.reload.should_not be_approved
        described_class.approve!("current dependency")
        dep.reload.should be_approved
      end

      it "should raise an error if it can't find the dependency" do
        expect { described_class.approve!("non-existent dependency") }
          .to raise_error(LicenseFinder::Error)
      end
    end

    describe ".license!" do
      let(:dependency) { double(:dependency) }

      it "adds a license for the dependency" do
        DependencyManager.stub(:find_by_name).with("dependency").and_return(dependency)
        dependency.should_receive(:set_license_manually!).with("MIT")
        described_class.license!("dependency", "MIT")
      end

      it "should raise an error if it can't find the dependency" do
        expect { described_class.license!("non-existent dependency", "a license") }
          .to raise_error(LicenseFinder::Error)
      end
    end

    describe ".modifying" do
      context "when the database doesn't exist" do
        before { File.stub(:exists?) { false } }

        it "writes reports" do
          Reporter.should_receive(:write_reports)
          DependencyManager.modifying {}
        end
      end

      context "when the database exists" do
        before { File.stub(:exists?) { true } }

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

          it "does not write reports" do
            Reporter.should_not_receive(:write_reports)
            DependencyManager.modifying {}
          end
        end

        context "when the reports do not exist" do
          before do
            Digest::SHA2.stub_chain(:file, :hexdigest) { 5 }
            File.stub(:exists?).with(LicenseFinder.config.artifacts.dependencies_html) { false }
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
