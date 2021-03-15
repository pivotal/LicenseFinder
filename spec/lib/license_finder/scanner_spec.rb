# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Scanner do
    let(:logger) { double(:logger, debug: true, info: true) }
    let(:enabled_package_manager_ids) { nil }
    let(:config) { { logger: logger, project_path: Pathname.new(''), enabled_package_manager_ids: enabled_package_manager_ids } }
    let(:subject) { described_class.new(config) }

    describe '#active_packages' do
      let(:bundler) { Bundler.new(ignored_groups: Set.new, definition: double(:definition, groups: [])) }

      before do
        allow(Bundler).to receive(:new).and_return bundler
        allow(bundler).to receive(:current_packages_with_relations)
        allow(bundler).to receive(:active?).and_return true
        allow(bundler).to receive(:package_management_command).and_return 'command'
      end

      context 'when package manager is installed' do
        it 'should log all active packages' do
          allow(bundler).to receive(:command_exists?).and_return true
          expect(logger).to receive(:debug).with(Bundler, 'is installed', color: :green)
          expect(subject.active_packages).to_not be_nil
        end
      end

      context 'when package manager is NOT installed' do
        it 'should log all active packages' do
          allow(bundler).to receive(:command_exists?).and_return false
          expect(logger).to receive(:info).with(Bundler, 'is active', color: :green)
          expect(logger).to receive(:info).with(Bundler, 'is not installed', color: :red)
          expect(subject.active_packages).to_not be_nil
        end
      end
    end

    describe '#active_package_managers' do
      it 'should return active package managers' do
        bundler = double(:bundler, active?: true)
        allow(Bundler).to receive(:new).and_return bundler
        expect(subject.active_package_managers).to include bundler
      end

      it 'should log active states of package managers' do
        bundler = double(:bundler, active?: true)
        allow(Bundler).to receive(:new).and_return bundler
        expect(logger).to receive(:info).with(Bundler, 'is active', color: :green)

        subject.active_package_managers
      end

      it 'should log inactive states of package managers' do
        bundler = double(:bundler, active?: false)
        allow(Bundler).to receive(:new).and_return bundler
        expect(logger).to receive(:debug).with(Bundler, 'is not active', color: :red)

        subject.active_package_managers
      end

      it 'should exclude GoVendor when Gvt is active' do
        gvt = Gvt.new
        allow(Gvt).to receive(:new).and_return gvt
        allow(gvt).to receive(:active?).and_return true
        govendor = Go15VendorExperiment.new
        allow(Go15VendorExperiment).to receive(:new).and_return govendor
        allow(govendor).to receive(:active?).and_return true
        expect(subject.active_package_managers).to include gvt
        expect(subject.active_package_managers).not_to include govendor
      end

      context 'when there are no active package managers' do
        it 'should show an appropriate error message' do
          described_class::PACKAGE_MANAGERS.each do |pm|
            d = double(pm.name, active?: false, class: pm)
            allow(pm).to receive(:new).and_return d
          end
          expect(logger).to receive(:info).with('License Finder', 'No active and installed package managers found for project.', color: :red)
          subject.active_package_managers
        end
      end

      context 'when package managers to enable are specified' do
        let(:enabled_package_manager_ids) { %w[gomodules bundler] }

        it 'should returns active package managers among those specified' do
          bundler = double(:bundler, active?: true)
          allow(Bundler).to receive(:new).and_return bundler

          npm = double(:npm, active?: true)
          allow(NPM).to receive(:new).and_return npm

          expect(subject.active_package_managers).to contain_exactly(bundler)
        end
      end

      context 'when unsupported package managers to enable are specified' do
        let(:enabled_package_manager_ids) { %w[bundler unsupported invalid] }

        it 'should throws an exception' do
          bundler = double(:bundler, active?: true)
          allow(Bundler).to receive(:new).and_return bundler

          expect { subject.active_package_managers }.to raise_error('Unsupported package manager: unsupported, invalid')
        end
      end
    end

    describe '#remove_subprojects' do
      let!(:project_root) { fixture_path('project-with-subprojects') }
      let!(:subproject_1) { fixture_path('project-with-subprojects/submodule-1') }
      let!(:non_subproject_1) { fixture_path('project-with-subprojects/not-submodule-1') }

      context 'receives a list of directories where some are subprojects' do
        it 'returns a list of project roots only' do
          project_roots = [
            project_root.to_s,
            subproject_1.to_s
          ]
          allow(Scanner).to receive(:subproject?).with(project_root).and_return(false)
          allow(Scanner).to receive(:subproject?).with(subproject_1).and_return(true)

          expect(Scanner.remove_subprojects(project_roots)).to eq([project_root.to_s])
        end
      end

      context 'when a directory has multiple package managers and at least one of them is a project root' do
        let!(:subproject_with_two_package_managers) { fixture_path('gradle-with-subprojects/submodule-2') }

        it 'returns a list of project roots including it' do
          project_roots = [
            fixture_path('gradle-with-subprojects').to_s,
            fixture_path('gradle-with-subprojects/submodule-1').to_s,
            subproject_with_two_package_managers.to_s
          ]
          expect(Scanner.remove_subprojects(project_roots))
            .to eq([fixture_path('gradle-with-subprojects').to_s, subproject_with_two_package_managers.to_s])
        end
      end

      context 'there are no subprojects' do
        it 'does not remove anything' do
          project_roots = [
            project_root.to_s,
            non_subproject_1.to_s
          ]
          allow(Scanner).to receive(:subproject?).with(project_root).and_return(false)
          allow(Scanner).to receive(:subproject?).with(non_subproject_1).and_return(false)

          expect(Scanner.remove_subprojects(project_roots))
            .to eq([project_root.to_s, non_subproject_1.to_s])
        end
      end
    end
  end
end
