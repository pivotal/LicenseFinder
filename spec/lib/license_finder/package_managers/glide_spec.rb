require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Glide do
    it_behaves_like 'a PackageManager'

    subject {Glide.new(project_path: Pathname('/app'), logger: double(:logger, active: nil, log: true))}

    context 'when lock file is contained in src folder' do
      it 'should return active' do
        FakeFS.with_fresh do
          FileUtils.mkdir_p '/app/src'
          File.write(Pathname('/app/src/glide.lock').to_s, '')
          expect(subject.active?).to be_truthy
        end
      end
    end

    context 'when lock file is contained in root folder' do
      it 'should return active' do
        FakeFS.with_fresh do
          FileUtils.mkdir_p '/app'
          File.write(Pathname('/app/glide.lock').to_s, '')
          expect(subject.active?).to be_truthy
        end
      end
    end

    describe '#current_packages' do
      it 'returns the packages described by glide.lock' do
        FakeFS.with_fresh do
          FileUtils.mkdir_p '/app/src'
          File.write(Pathname('/app/src/glide.lock').to_s,
                     'imports:
- name: some-package-name
  version: 123abc
  repo: example.com
- name: another-package-name
  version: 456xyz')
          expect(subject.current_packages.length).to eq 2

          expect(subject.current_packages.first.name).to eq 'some-package-name'
          expect(subject.current_packages.first.version).to eq '123abc'

          expect(subject.current_packages.last.name).to eq 'another-package-name'
          expect(subject.current_packages.last.version).to eq '456xyz'
        end
      end
    end

    describe '.prepare_method' do
      it 'returns the correct prepare method' do
        expect(described_class.prepare_method).to eq('glide install')
      end
    end

    describe '.package_management_command' do
      it 'returns the correct package management command' do
        expect(described_class.package_management_command).to eq('glide')
      end
    end
  end
end
