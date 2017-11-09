require 'spec_helper'

module LicenseFinder
  describe PackageManager do
    let(:logger) { double(:logger, debug: true, info: true) }

    describe '#current_packages_with_relations' do
      it "sets packages' parents" do
        grandparent = Package.new('grandparent', nil, children: ['parent'])
        parent      = Package.new('parent',      nil, children: ['child'])
        child       = Package.new('child')

        pm = described_class.new
        allow(pm).to receive(:current_packages) { [grandparent, parent, child] }

        expect(pm.current_packages_with_relations.map(&:parents)).to eq([
                                                                          [].to_set,
                                                                          ['grandparent'].to_set,
                                                                          ['parent'].to_set
                                                                        ])
      end
    end

    describe '.package_management_command' do
      it 'defaults to nil' do
        expect(LicenseFinder::PackageManager.package_management_command).to be_nil
      end
    end

    describe '.installed?' do
      context 'package_management_command is nil' do
        before do
          allow(LicenseFinder::PackageManager).to receive(:package_management_command).and_return(nil)
        end

        it 'returns true' do
          expect(LicenseFinder::PackageManager.installed?).to be_truthy
        end
      end

      context 'package_management_command exists' do
        before do
          allow(LicenseFinder::PackageManager).to receive(:package_management_command).and_return('foobar')
          allow(LicenseFinder::PackageManager).to receive(:command_exists?).with('foobar').and_return(true)
        end

        it 'returns true' do
          expect(LicenseFinder::PackageManager.installed?).to be_truthy
        end
      end

      context 'package_management_command does not exist' do
        before do
          allow(LicenseFinder::PackageManager).to receive(:package_management_command).and_return('foobar')
          allow(LicenseFinder::PackageManager).to receive(:command_exists?).with('foobar').and_return(false)
        end

        it 'returns false' do
          expect(LicenseFinder::PackageManager.installed?(logger)).to be_falsey
        end
      end
    end

    describe '.active_package_managers' do
      it 'should return active package managers' do
        bundler = double(:bundler, active?: true)
        allow(Bundler).to receive(:new).and_return bundler
        expect(LicenseFinder::PackageManager.active_package_managers(logger: logger, project_path: Pathname.new(''))).to include bundler
      end

      it 'should log active states of package managers' do
        bundler = double(:bundler, active?: true)
        allow(Bundler).to receive(:new).and_return bundler
        expect(logger).to receive(:info).with(Bundler, 'is active', color: :green)

        LicenseFinder::PackageManager.active_package_managers(logger: logger, project_path: Pathname.new(''))
      end

      it 'should log inactive states of package managers' do
        bundler = double(:bundler, active?: true)
        allow(Bundler).to receive(:new).and_return bundler
        inactive_managers = LicenseFinder::PackageManager.package_managers - [Bundler]

        inactive_managers.each do |pm|
          expect(logger).to receive(:debug).with(pm, 'is not active', color: :red)
        end

        LicenseFinder::PackageManager.active_package_managers(logger: logger, project_path: Pathname.new(''))
      end

      it 'should exclude GoVendor when Gvt is active' do
        gvt = Gvt.new
        allow(Gvt).to receive(:new).and_return gvt
        allow(gvt).to receive(:active?).and_return true
        govendor = Go15VendorExperiment.new
        allow(Go15VendorExperiment).to receive(:new).and_return govendor
        allow(govendor).to receive(:active?).and_return true
        expect(LicenseFinder::PackageManager.active_package_managers(logger: logger, project_path: Pathname.new(''))).to include gvt
        expect(LicenseFinder::PackageManager.active_package_managers(logger: logger, project_path: Pathname.new(''))).not_to include govendor
      end
    end

    describe '.active_packages' do
      before do
        bundler = double(:bundler, active?: true, class: Bundler)
        allow(Bundler).to receive(:new).and_return bundler
        allow(bundler).to receive(:current_packages_with_relations)
        allow(Bundler).to receive(:package_management_command).and_return 'command'
      end

      context 'when package manager is installed' do
        it 'should log all active packages' do
          allow(Bundler).to receive(:command_exists?).and_return true
          expect(logger).to receive(:debug).with(Bundler, 'is installed', color: :green)
          expect(LicenseFinder::PackageManager.active_packages(logger: logger, project_path: Pathname.new(''))).to_not be_nil
        end
      end

      context 'when package manager is NOT installed' do
        it 'should log all active packages' do
          allow(Bundler).to receive(:command_exists?).and_return false
          expect(logger).to receive(:info).with(Bundler, 'is active', color: :green)
          expect(logger).to receive(:info).with(Bundler, 'is not installed', color: :red)
          expect(LicenseFinder::PackageManager.active_packages(logger: logger, project_path: Pathname.new(''))).to_not be_nil
        end
      end
    end

    describe '#prepare' do
      context 'when there is a prepare_command' do
        before do
          allow(described_class).to receive(:prepare_command).and_return('sh commands')
        end

        it 'succeeds when prepare command runs successfully' do
          expect(SharedHelpers::Cmd).to receive(:run).with('sh commands').and_return(['output', nil, cmd_success])

          expect { subject.prepare }.to_not raise_error
        end

        it 'raises exception when prepare command runs into failure' do
          expect(SharedHelpers::Cmd).to receive(:run).with('sh commands').and_return(['output', nil, cmd_failure])

          expect { subject.prepare }.to raise_error("Prepare command 'sh commands' failed")
        end
      end

      context 'when there is no prepare_command' do
        it 'issues a warning' do
          logger = double(:logger)
          expect(logger).to receive(:debug).with(described_class, 'no prepare step provided', color: :red)
          expect(SharedHelpers::Cmd).to_not receive(:run).with('sh commands')

          subject = described_class.new logger: logger
          subject.prepare
        end
      end
    end
  end
end
