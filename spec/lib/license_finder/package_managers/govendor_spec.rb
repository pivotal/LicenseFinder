require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Govendor do
    it_behaves_like 'a PackageManager'
    describe '#current_packages' do
      subject { Govendor.new(project_path: Pathname('/app'), logger: double(:logger, active: nil)) }

      it 'returns the packages described by vendor/vendor.json' do
        FakeFS do
          FileUtils.mkdir_p '/app/vendor'
          File.write(
            '/app/vendor/vendor.json',
            '
            {
              "comment": "",
              "ignore": "test",
              "package": [
                {
                  "checksumSHA1": "4Tc07iR3HloUYC4HNT4xc0875WY=",
                  "path": "foo/Bowery/prompt",
                  "revision": "0f1139e9a1c74b57ccce6bdb3cd2f7cd04dd3449",
                  "revisionTime": "2017-02-19T07:16:37Z"
                },
                {
                  "checksumSHA1": "6VGFARaK8zd23IAiDf7a+gglC8k=",
                  "path": "foo/dchest/safefile",
                  "revision": "855e8d98f1852d48dde521e0522408d1fe7e836a",
                  "revisionTime": "2015-10-22T12:31:44+02:00"
                }
              ],
              "rootPath": "foo/kardianos/govendor"
            }
            '
          )

          expect(subject.current_packages.length).to eq 2

          expect(subject.current_packages.first.name).to eq 'foo/Bowery/prompt'
          expect(subject.current_packages.first.version).to eq '0f1139e9a1c74b57ccce6bdb3cd2f7cd04dd3449'

          expect(subject.current_packages.last.name).to eq 'foo/dchest/safefile'
          expect(subject.current_packages.last.version).to eq '855e8d98f1852d48dde521e0522408d1fe7e836a'
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
