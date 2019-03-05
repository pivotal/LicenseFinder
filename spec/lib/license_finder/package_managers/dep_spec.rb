# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Dep do
    it_behaves_like 'a PackageManager'
    describe '#current_packages' do
      subject { Dep.new(project_path: Pathname('/app'), logger: double(:logger, active: nil)) }
      let(:content) do
        FakeFS.without do
          fixture_from('gopkg.lock')
        end
      end

      it 'returns the packages described by Gopkg.lock' do
        FakeFS do
          FileUtils.mkdir_p '/app'
          File.write('/app/Gopkg.lock', content)
          expect(subject.current_packages.length).to eq 3

          expect(subject.current_packages.first.name).to eq 'github.com/Bowery/prompt'
          expect(subject.current_packages.first.version).to eq '0f1139e9a1c74b57ccce6bdb3cd2f7cd04dd3449'

          expect(subject.current_packages[1].name).to eq 'github.com/dchest/safefile'
          expect(subject.current_packages[1].version).to eq '855e8d98f1852d48dde521e0522408d1fe7e836a'

          expect(subject.current_packages.last.name).to eq 'golang.org/x/sys'
          expect(subject.current_packages.last.version).to eq 'ebfc5b4631820b793c9010c87fd8fef0f39eb082'
        end
      end

      context 'the package does not have any projects in its toml' do
        before do
          allow(TOML).to receive(:load_file).and_return({})
        end

        it 'should return an empty array' do
          expect(subject.current_packages).to eq([])
        end
      end
    end

    describe '.prepare_command' do
      it 'returns the correct prepare method' do
        expect(described_class.prepare_command).to eq('dep ensure -vendor-only')
      end
    end

    describe '.package_management_command' do
      it 'returns the correct package management command' do
        expect(described_class.package_management_command).to eq('dep')
      end
    end
  end
end
