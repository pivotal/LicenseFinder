# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Govendor do
    it_behaves_like 'a PackageManager'
    describe '#current_packages' do
      subject { Govendor.new(project_path: Pathname('/app'), logger: double(:logger, active: nil)) }

      let(:content) do
        FakeFS.without do
          fixture_from('govendor.json')
        end
      end

      it 'returns the packages described by vendor/vendor.json' do
        FakeFS do
          FileUtils.mkdir_p '/app/vendor'
          File.write('/app/vendor/vendor.json', content)

          expect(subject.current_packages.length).to eq 2

          expect(subject.current_packages.first.name).to eq 'foo/Bowery/prompt'
          expect(subject.current_packages.first.version).to eq '0f1139e9a1c74b57ccce6bdb3cd2f7cd04dd3449'

          expect(subject.current_packages.last.name).to eq 'foo/dchest/safefile'
          expect(subject.current_packages.last.version).to eq '855e8d98f1852d48dde521e0522408d1fe7e836a'
        end
      end

      context 'when there are common paths' do
        let(:content) do
          FakeFS.without do
            fixture_from('govendor_common_paths.json')
          end
        end

        it 'returns the packages described by vendor/vendor.json with commmon paths consolidated' do
          FakeFS do
            FileUtils.mkdir_p '/app/vendor'
            File.write('/app/vendor/vendor.json', content)

            expect(subject.current_packages.length).to eq 1

            expect(subject.current_packages.first.name).to eq 'foo/Bowery'
            expect(subject.current_packages.first.version).to eq '0f1139e9a1c74b57ccce6bdb3cd2f7cd04dd3449'
          end
        end
      end
    end

    describe '.prepare_command' do
      it 'returns the correct prepare method' do
        expect(described_class.prepare_command).to eq('govendor sync')
      end
    end

    describe '.package_management_command' do
      it 'returns the correct package management command' do
        expect(described_class.package_management_command).to eq('govendor')
      end
    end
  end
end
