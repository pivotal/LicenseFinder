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

    describe ".package_management_command" do
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

    describe ".active_package_managers" do

      it "should return active package managers" do
        bundler = double(:bundler, :active? => true)
        allow(Bundler).to receive(:new).and_return bundler
        expect(LicenseFinder::PackageManager.active_package_managers).to include bundler
      end

      it "should exclude GoVendor when Gvt is active" do
        gvt = Gvt.new
        allow(Gvt).to receive(:new).and_return gvt
        allow(gvt).to receive(:active?).and_return true
        govendor = Go15VendorExperiment.new
        allow(Go15VendorExperiment).to receive(:new).and_return govendor
        allow(govendor).to receive(:active?).and_return true
        expect(LicenseFinder::PackageManager.active_package_managers).to include gvt
        expect(LicenseFinder::PackageManager.active_package_managers).not_to include govendor
      end
    end

    describe '#prepare' do
      context 'when there is a prepare_command' do
        before do
          allow(described_class).to receive(:prepare_command).and_return('sh commands')
        end

        it 'succeeds when prepare command runs successfully' do
          expect(subject).to receive(:capture).with('sh commands').and_return(['output', true])

          expect { subject.prepare }.to_not raise_error
        end

        it 'raises exception when prepare command runs into failure' do
          expect(subject).to receive(:capture).with('sh commands').and_return(['output', false])

          expect { subject.prepare }.to raise_error("Prepare command 'sh commands' failed")
        end
      end

      context 'when there is no prepare_command' do
        it 'issues a warning' do
          logger = double(:logger)
          expect(logger).to receive(:log).with(described_class, Logger.red('no prepare step provided'))
          expect(subject).to_not receive(:capture).with('sh commands')

          subject = described_class.new logger: logger
          subject.prepare
        end
      end
    end
  end
end
