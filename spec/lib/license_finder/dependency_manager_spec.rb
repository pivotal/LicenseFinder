require 'spec_helper'
require 'digest'

module LicenseFinder
  describe DependencyManager do
    let(:config) { Configuration.new }

    before do
      LicenseFinder.stub(:config).and_return config
      config.whitelist = ["MIT", "other"]
      Reporter.stub(:write_reports)
    end

    describe "#sync_with_bundler" do
      let(:gem1) { double(:bundled_gem) }
      let(:gem2) { double(:bundled_gem) }

      it "destroys every dependency except for the ones Bundler reports as 'current' or are marked as 'manual'" do
        cur1 = Dependency.create(name: "current dependency 1")
        cur2 = Dependency.create(name: "current dependency 2")
        man1 = Dependency.create(name: "manual dependency", manual: true)
        Dependency.create(name: "old dependency 1")
        Dependency.create(name: "old dependency 2")

        current_gems = [gem1, gem2]
        Bundle.stub(:current_gems).with(config) { current_gems }
        BundledGemSaver.should_receive(:save_gems).with(current_gems).and_return([cur1, cur2])

        described_class.sync_with_bundler
        Dependency.all.map(&:name).should =~ [cur1, cur2, man1].map(&:name)
      end
    end

    describe ".create_non_bundler" do
      it "should add a Dependency" do
        expect do
          described_class.create_non_bundler("MIT", "js_dep", "0.0.0")
        end.to change(Dependency, :count).by(1)
      end

      it "should mark the dependency as manual" do
        described_class.create_non_bundler("MIT", "js_dep", "0.0.0")
          .should be_manual
      end

      it "should set the appropriate values" do
        dep = described_class.create_non_bundler("GPL", "js_dep", "0.0.0")
        dep.name.should == "js_dep"
        dep.version.should == "0.0.0"
        dep.license.name.should == "GPL"
        dep.should_not be_approved
      end

      it "should complain if the dependency already exists" do
        Dependency.create(name: "current dependency 1")
        expect { described_class.create_non_bundler("GPL", "current dependency 1", "0.0.0") }
          .to raise_error(LicenseFinder::Error)
      end
    end

    describe ".destroy_non_bundler" do
      it "should remove a non bundler Dependency" do
        described_class.create_non_bundler("GPL", "a non-bundler dep", nil)
        expect do
          described_class.destroy_non_bundler("a non-bundler dep")
        end.to change(Dependency, :count).by(-1)
      end

      it "should not remove a bundler Dependency" do
        Dependency.create(name: "a bundler dep")
        expect do
          expect do
            described_class.destroy_non_bundler("a bundler dep")
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
            File.stub(:exists?).with(LicenseFinder.config.dependencies_html) { false }
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
