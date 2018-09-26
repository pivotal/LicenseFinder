# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Glide do
    it_behaves_like 'a PackageManager'

    subject { Glide.new(project_path: Pathname('/app'), logger: double(:logger, active: nil, log: true)) }

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
      let(:content) do
        FakeFS.without do
          fixture_from('glide.yml')
        end
      end
      it 'returns the packages described by glide.lock' do
        FakeFS.with_fresh do
          FileUtils.mkdir_p '/app/src'
          File.write(Pathname('/app/src/glide.lock').to_s, content)
          expect(subject.current_packages.length).to eq 2

          expect(subject.current_packages.first.name).to eq 'some-package-name'
          expect(subject.current_packages.first.version).to eq '123abc'

          expect(subject.current_packages.last.name).to eq 'another-package-name'
          expect(subject.current_packages.last.version).to eq '456xyz'
        end
      end

      context 'when there is a src directory' do
        it 'looks for licenses under src/vendor directory' do
          FakeFS.with_fresh do
            FileUtils.mkdir_p '/app/src'
            File.write(Pathname('/app/src/glide.lock').to_s, content)

            subject.current_packages.each do |package|
              expect(package.install_path).to eq(Pathname("/app/src/vendor/#{package.name}"))
            end
          end
        end
      end

      context 'when there is not src directory' do
        it 'looks for licenses under vendor directory' do
          FakeFS.with_fresh do
            FileUtils.mkdir_p '/app'
            File.write(Pathname('/app/glide.lock').to_s, content)

            subject.current_packages.each do |package|
              expect(package.install_path).to eq(Pathname("/app/vendor/#{package.name}"))
            end
          end
        end
      end
    end

    describe '.prepare_command' do
      it 'returns the correct prepare method' do
        expect(described_class.prepare_command).to eq('glide install')
      end
    end

    describe '.package_management_command' do
      it 'returns the correct package management command' do
        expect(described_class.package_management_command).to eq('glide')
      end
    end
  end
end
