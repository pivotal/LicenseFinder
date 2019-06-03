# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe GoModules do
    it_behaves_like 'a PackageManager'

    let(:src_path) { '/workspace/code' }
    let(:sum_path) { "#{src_path}/go.sum" }
    let(:vendor_path) { "#{src_path}/vendor" }
    let(:go_list_string) do
      "foo,,/workspace/code/\ngopkg.in/check.v1,v0.0.0-20161208181325-20d25e280405,"\
"/workspace/LicenseFinder/features/fixtures/go_modules/vendor/gopkg.in/check.v1\n"\
'gopkg.in/yaml.v2,v2.2.1,/workspace/LicenseFinder/features/fixtures/go_modules/vendor/gopkg.in/yaml.v2'
    end
    subject { GoModules.new(project_path: Pathname(src_path), logger: double(:logger, active: nil)) }

    describe '#current_packages' do
      before do
        FakeFS.activate!

        FileUtils.mkdir_p(vendor_path)
        File.write(sum_path, content)

        allow(SharedHelpers::Cmd).to receive(:run).with("GO111MODULE=on go list -m -mod=vendor -f '{{.Path}},{{.Version}},{{.Dir}}' all").and_return(go_list_string)
      end

      after do
        FakeFS.deactivate!
      end

      let(:content) do
        FakeFS.without do
          fixture_from('go.sum')
        end
      end

      it 'finds all the packages all go.sum files' do
        packages = subject.current_packages

        expect(packages.length).to eq 2

        expect(packages.first.name).to eq 'gopkg.in/check.v1'
        expect(packages.first.version).to eq 'v0.0.0-20161208181325-20d25e280405'

        expect(packages.last.name).to eq 'gopkg.in/yaml.v2'
        expect(packages.last.version).to eq 'v2.2.1'
      end

      it 'list packages as Go packages' do
        packages = subject.current_packages

        expect(packages.first.package_manager).to eq 'Go'
      end
    end

    describe '.prepare_command' do
      it 'returns the correct package management command' do
        expect(described_class.prepare_command).to eq('GO111MODULE=on go mod tidy && GO111MODULE=on go mod vendor')
      end
    end

    describe '.takes_priority_over' do
      it 'returns the package manager it takes priority over' do
        expect(described_class.takes_priority_over).to eq(Go15VendorExperiment)
      end
    end
  end
end
