# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Trash do
    it_behaves_like 'a PackageManager'

    subject { Trash.new(project_path: Pathname('/app'), logger: double(:logger, active: nil, log: true)) }

    describe '.prepare_command' do
      it 'returns the correct prepare method' do
        expect(described_class.prepare_command).to eq('trash')
      end
    end

    describe '.package_management_command' do
      it 'returns the correct package management command' do
        expect(described_class.package_management_command).to eq('trash')
      end
    end

    describe '.takes_priority_over' do
      it 'returns the package manager it takes priority over' do
        expect(described_class.takes_priority_over).to eq(Go15VendorExperiment)
      end
    end

    describe '#current_packages' do
      let(:content) do
        FakeFS.without do
          fixture_from('trash.lock')
        end
      end

      it 'returns the packages described by trash.lock' do
        FakeFS.with_fresh do
          FileUtils.mkdir_p '/app'
          File.write(Pathname('/app/trash.lock').to_s, content)
          expect(subject.current_packages.length).to eq 2

          expect(subject.current_packages.first.name).to eq 'some-package-name'
          expect(subject.current_packages.first.version).to eq '123abc'

          expect(subject.current_packages.last.name).to eq 'another-package-name'
          expect(subject.current_packages.last.version).to eq '456xyz'
        end
      end
    end
  end
end
