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

      context 'when revisions are blank' do
        let(:content) do
          <<~PACKAGES
            {
              "package": [
                {
                  "path": "foo/Bowery/prompt",
                  "revision": "",
                  "revisionTime": "2017-02-19T07:16:37Z"
                },
                {
                  "path": "foo/Bowery/safefile",
                  "revision": "",
                  "revisionTime": "2015-10-22T12:31:44+02:00"
                }
              ]
            }
          PACKAGES
        end

        before do
          FakeFS.activate!
          FileUtils.mkdir_p '/app/vendor'
          File.write('/app/vendor/vendor.json', content)
        end

        after do
          FakeFS.deactivate!
        end

        it 'should not mistake them as having common paths' do
          expect(subject.current_packages.length).to eq 2

          expect(subject.current_packages[0].name).to eq 'foo/Bowery/prompt'
          expect(subject.current_packages[0].version).to eq ''

          expect(subject.current_packages[1].name).to eq 'foo/Bowery/safefile'
          expect(subject.current_packages[1].version).to eq ''
        end
      end

      context 'when origin is defined for a package' do
        let(:content) do
          FakeFS.without do
            fixture_from('govendor_with_origin.json')
          end
        end

        before do
          FakeFS.activate!
          FileUtils.mkdir_p '/app/vendor'
          File.write('/app/vendor/vendor.json', content)
        end

        after do
          FakeFS.deactivate!
        end

        it 'uses origin as path' do
          expect(subject.current_packages.length).to eq 2

          expect(subject.current_packages[0].name).to eq 'foo/Bowery/prompt/origin'
          expect(subject.current_packages[1].name).to eq 'foo/dchest/safefile'
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
