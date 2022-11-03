# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'
require 'json'

module LicenseFinder
  describe PNPM do
    let(:root) { '/fake-node-project' }
    it_behaves_like 'a PackageManager'

    let(:pnpm_shell_command_output) do
      {
        "MIT": [
          {
            "name": "yn",
            "version": "2.0.0",
            "path": Pathname(root).join('node_modules', 'yn'),
            "license": "MIT",
            "vendorUrl": "sindresorhus.com",
            "vendorName": "Sindre Sorhus"
          }
        ]
      }.to_json
    end

    let(:pnpm_incompatible_packages_shell_output) do
      {
        "MIT": [
          {
            "name": "fsevents",
            "version": "1.1.1",
            "path": Pathname(root).join('node_modules', 'fsevents'),
            "license": "Unknown",
            "vendorUrl": "github.com/fsevents/fsevents",
          }
        ]
      }.to_json
    end

    describe '.prepare' do
      subject { PNPM.new(project_path: Pathname(root), logger: double(:logger, active: nil)) }

      include FakeFS::SpecHelpers
      before do
        FileUtils.mkdir_p(Dir.tmpdir)
        FileUtils.mkdir_p(root)
      end

      context 'when using PNPM 6 throws error' do
        before do
          allow(SharedHelpers::Cmd).to receive(:run).with('pnpm -v').and_return(['6.1.4', '', cmd_success])
        end

        context 'when the shell command fails' do
          it 'an error is raised' do
            allow(SharedHelpers::Cmd).to receive(:run).with(PNPM::SHELL_COMMAND + " #{Pathname(root)}").and_return([nil, 'error', cmd_failure])

            expect { subject.current_packages }.to raise_error(/The minimum PNPM version is not met, requires 7.14.1 or later/)
          end
        end
      end

      context 'when using PNPM projects' do
        before do
          allow(SharedHelpers::Cmd).to receive(:run).with('pnpm -v').and_return(['2.0.1', '', cmd_success])
        end

        it 'should call pnpm install with no cli parameters' do
          expect(SharedHelpers::Cmd).to receive(:run).with('pnpm install --no-lockfile --ignore-scripts').and_return([pnpm_shell_command_output, '', cmd_success])
          subject.prepare
        end

        context 'ignored_groups contains devDependencies' do
          subject { PNPM.new(project_path: Pathname(root), ignored_groups: 'devDependencies') }

          it 'should include a production flag' do
            expect(SharedHelpers::Cmd).to receive(:run).with('pnpm install --no-lockfile --ignore-scripts --prod').and_return([pnpm_shell_command_output, '', cmd_success])
            subject.prepare
          end
        end
      end
    end

    describe '.prepare_command' do
      include FakeFS::SpecHelpers
      before do
        FileUtils.mkdir_p(Dir.tmpdir)
        FileUtils.mkdir_p(root)
      end

      context 'when in a PNPM project' do
        before do
          allow(SharedHelpers::Cmd).to receive(:run).with('pnpm -v').and_return(['7.14.1', '', cmd_success])
        end

        subject { PNPM.new(project_path: Pathname(root), logger: double(:logger, active: nil)) }
        it 'returns the correct prepare method' do
          expect(subject.prepare_command).to eq('pnpm install --no-lockfile --ignore-scripts')
        end
      end
    end

    describe '#current_packages' do
      subject { PNPM.new(project_path: Pathname(root), logger: double(:logger, active: nil)) }

      include FakeFS::SpecHelpers
      before do
        FileUtils.mkdir_p(Dir.tmpdir)
        FileUtils.mkdir_p(root)
        allow(SharedHelpers::Cmd).to receive(:run).with('pnpm -v').and_return(['7.14.1', '', cmd_success])
      end

      context 'when using PNPM 7.14.1+' do
        before do
          allow(SharedHelpers::Cmd).to receive(:run).with('pnpm -v').and_return(['7.14.1', '', cmd_success])
        end
      end

      it 'displays packages as returned from "pmpm list"' do
        allow(SharedHelpers::Cmd).to receive(:run).with(PNPM::SHELL_COMMAND + " --no-color --dir #{Pathname(root)}") do
          [pnpm_shell_command_output, '', cmd_success]
        end

        expect(subject.current_packages.length).to eq 1
        expect(subject.current_packages.first.name).to eq 'yn'
        expect(subject.current_packages.first.version).to eq '2.0.0'
        expect(subject.current_packages.first.license_names_from_spec).to eq ['MIT']
        expect(subject.current_packages.first.homepage).to eq 'sindresorhus.com'
        expect(subject.current_packages.first.authors).to eq 'Sindre Sorhus'
        expect(subject.current_packages.first.install_path).to eq Pathname(root).join('node_modules', 'yn').to_s
      end

      it 'displays incompatible packages with license type unknown' do
        allow(SharedHelpers::Cmd).to receive(:run).with(PNPM::SHELL_COMMAND + " --no-color --dir #{Pathname(root)}") do
          [pnpm_incompatible_packages_shell_output, '', cmd_success]
        end

        expect(subject.current_packages.length).to eq 1
        expect(subject.current_packages.last.name).to eq 'fsevents'
        expect(subject.current_packages.last.version).to eq '1.1.1'
        expect(subject.current_packages.last.license_names_from_spec).to eq ['Unknown']
      end

      context 'ignored_groups contains devDependencies' do
        subject { PNPM.new(project_path: Pathname(root), ignored_groups: 'devDependencies') }
        it 'should include a production flag' do
          expect(SharedHelpers::Cmd).to receive(:run).with("#{PNPM::SHELL_COMMAND} --no-color --dir #{Pathname(root)}")
                                                     .and_return([pnpm_shell_command_output, '', cmd_success])
          subject.current_packages
        end
      end

      context 'when the shell command fails' do
        it 'an error is raised' do
          allow(SharedHelpers::Cmd).to receive(:run).with(PNPM::SHELL_COMMAND + " --no-color --dir #{Pathname(root)}").and_return([nil, 'error', cmd_failure])

          expect { subject.current_packages }.to raise_error(/Command 'pnpm licenses --json --long --no-color --dir #{Pathname(root)}' failed to execute: error/)
        end
      end
    end

    describe '.package_management_command' do
      it 'returns the correct package management command' do
        expect(subject.package_management_command).to eq('pnpm')
      end
    end
  end
end
