# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Gvt do
    it_behaves_like 'a PackageManager'

    let(:content) do
      FakeFS.without do
        fixture_from('gvt.json')
      end
    end

    describe '#current_packages' do
      subject { Gvt.new(project_path: Pathname('/app'), logger: double(:logger, active: nil)) }

      before do
        FakeFS.activate!
      end

      after do
        FakeFS.deactivate!
      end

      context 'when the \'vendor\' folder is not nested in another folder' do
        include FakeFS::SpecHelpers
        it "returns the packages described by 'gvt list'" do
          FileUtils.mkdir_p '/app/vendor'
          File.write('/app/vendor/manifest', content)
          allow(SharedHelpers::Cmd).to receive(:run).with('cd /app && gvt list -f "{{.Importpath}} {{.Revision}} {{.Repository}}"') do
            ["my-package-name 123abc example.com\npackage-name-2 456xyz anotherurl.com", '', cmd_success]
          end
          expect(subject.current_packages.length).to eq 2

          first = subject.current_packages.first
          expect(first.name).to eq 'my-package-name'
          expect(first.install_path).to eq Pathname('/app/vendor/my-package-name')
          expect(first.version).to eq '123abc'
          expect(first.homepage).to eq 'example.com'

          last = subject.current_packages.last
          expect(last.name).to eq 'package-name-2'
          expect(last.install_path).to eq Pathname('/app/vendor/package-name-2')
          expect(last.version).to eq '456xyz'
          expect(last.homepage).to eq 'anotherurl.com'
        end
      end

      context 'when the GVT returns entries with same sha with common base path' do
        let(:gvt_output_with_common_paths) do
          <<OUTPUT
cloud.google.com/go/bigquery abcd gcloud-repo
cloud.google.com/go/civil abcd gcloud-repo
cloud.google.com/go/compute/metadata abcd gcloud-repo
OUTPUT
        end
        let(:gvt_output_without_common_paths) do
          <<OUTPUT
cloud.google.com/go/bigquery/adsf abcd gcloud-repo
cloud.google.com/go/civil abcd gcloud-repo
cloud.aws.com/go/metadata abcd gcloud-repo
OUTPUT
        end

        before do
          FileUtils.mkdir_p '/app/vendor'
          File.write('/app/vendor/manifest', content)
        end

        it 'only shows the entry with common base path once' do
          allow(SharedHelpers::Cmd).to receive(:run).with('cd /app && gvt list -f "{{.Importpath}} {{.Revision}} {{.Repository}}"') do
            [gvt_output_with_common_paths, '', cmd_success]
          end
          expect(subject.current_packages.length).to eq 1

          package = subject.current_packages.first
          expect(package.name).to eq 'cloud.google.com/go'
          expect(package.install_path).to eq Pathname('/app/vendor/cloud.google.com/go')
          expect(package.version).to eq 'abcd'
          expect(package.homepage).to eq 'gcloud-repo'
        end

        it 'shows entries with same sha when they do not have a common base path' do
          allow(SharedHelpers::Cmd).to receive(:run).with('cd /app && gvt list -f "{{.Importpath}} {{.Revision}} {{.Repository}}"') do
            [gvt_output_without_common_paths, '', cmd_success]
          end

          expect(subject.current_packages.length).to eq 2

          first = subject.current_packages.first
          expect(first.name).to eq 'cloud.google.com/go'
          expect(first.install_path).to eq Pathname('/app/vendor/cloud.google.com/go')
          expect(first.version).to eq 'abcd'
          expect(first.homepage).to eq 'gcloud-repo'

          last = subject.current_packages.last
          expect(last.name).to eq 'cloud.aws.com/go/metadata'
          expect(last.install_path).to eq Pathname('/app/vendor/cloud.aws.com/go/metadata')
          expect(last.version).to eq 'abcd'
          expect(last.homepage).to eq 'gcloud-repo'
        end
      end

      it 'returns empty package list if \'gvt list\' fails' do
        allow(SharedHelpers::Cmd).to receive(:run).with(anything) do
          ["my-package-name 123abc example.com\npackage-name-2 456xyz anotherurl.com", '', cmd_failure]
        end
        expect(subject.current_packages).to eq []
      end
    end

    describe '.prepare_command' do
      it 'returns the correct gvt restore command' do
        expect(described_class.prepare_command).to eq('gvt restore')
      end
    end

    describe '.package_management_command' do
      it 'returns the correct package management command' do
        expect(described_class.package_management_command).to eq('gvt')
      end
    end
  end
end
