require 'spec_helper'
require 'fakefs/spec_helpers'
require 'json'

module LicenseFinder
  describe Yarn do
    it_behaves_like 'a PackageManager'

    let(:yarn_shell_command_output) do
      {
        'type' => 'table',
        'data' => {
          'body' => [['yn', '2.0.0', 'MIT', 'https://github.com/sindresorhus/yn.git', 'sindresorhus.com', 'Sindre Sorhus']],
          'head' => %w[Name Version License URL VendorUrl VendorName]
        }
      }.to_json
    end
    describe '#current_packages' do
      subject { Yarn.new(project_path: Pathname('/app'), logger: double(:logger, active: nil)) }

      it 'displays packages as returned from "yarn list"' do
        allow(SharedHelpers::Cmd).to receive(:run).with(Yarn::SHELL_COMMAND) do
          [yarn_shell_command_output, '', cmd_success]
        end

        expect(subject.current_packages.length).to eq 1
        expect(subject.current_packages.first.name).to eq 'yn'
        expect(subject.current_packages.first.version).to eq '2.0.0'
        expect(subject.current_packages.first.license_names_from_spec).to eq ['MIT']
        expect(subject.current_packages.first.homepage).to eq 'sindresorhus.com'
      end

      it 'displays incompatible packages with license type unknown' do
        allow(SharedHelpers::Cmd).to receive(:run).with(Yarn::SHELL_COMMAND) do
          ['{"type":"info","data":"fsevents@1.1.1: The platform \"linux\" is incompatible with this module."}
            {"type":"info","data":"\"fsevents@1.1.1\" is an optional dependency and failed compatibility check. Excluding it from installation."}', '', cmd_success]
        end

        expect(subject.current_packages.length).to eq 1
        expect(subject.current_packages.last.name).to eq 'fsevents'
        expect(subject.current_packages.last.version).to eq '1.1.1'
        expect(subject.current_packages.last.license_names_from_spec).to eq ['unknown']
      end
    end

    describe '.prepare_command' do
      it 'returns the correct prepare method' do
        expect(described_class.prepare_command).to eq('yarn install')
      end
    end

    describe '.package_management_command' do
      it 'returns the correct package management command' do
        expect(described_class.package_management_command).to eq('yarn')
      end
    end
  end
end
