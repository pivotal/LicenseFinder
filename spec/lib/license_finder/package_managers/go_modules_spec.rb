# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe GoModules do
    it_behaves_like 'a PackageManager'

    let(:src_path) { '/workspace/code' }
    let(:sum_path) { "#{src_path}/go.sum" }

    subject { GoModules.new(project_path: Pathname(src_path), logger: double(:logger, active: nil)) }

    describe '#current_packages' do
      before do
        FakeFS.activate!

        FileUtils.mkdir_p(src_path)
        File.write(sum_path, content)
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

      context 'when there are vendored dependencies' do
        let(:vendor_path) { "#{src_path}/vendor" }
        let(:vendored_dep1) { File.join(vendor_path, 'gopkg.in/check.v1') }
        let(:vendored_dep2) { File.join(vendor_path, 'gopkg.in/yaml.v2') }

        before do
          FakeFS.activate!

          FileUtils.mkdir_p(vendored_dep1)
          FileUtils.mkdir_p(vendored_dep2)
        end

        after do
          FileUtils.rm_r(vendored_dep1)
          FileUtils.rm_r(vendored_dep2)

          FakeFS.deactivate!
        end

        it 'sets the packages\' install_paths to the vendored directories' do
          packages = subject.current_packages

          expect(packages.first.install_path).to eq File.join(vendor_path, 'gopkg.in/check.v1')
          expect(packages.last.install_path).to eq File.join(vendor_path, 'gopkg.in/yaml.v2')
        end
      end

      context 'when there are no vendored dependencies' do
        context 'when GOPATH is configured' do
          let(:gopath) { '/some/path' }

          before do
            stub_const('ENV', 'GOPATH' => gopath)
          end

          it 'set the packages\' install_paths to the dependencies\' location in the GOPATH' do
            packages = subject.current_packages

            expect(packages.first.install_path).to eq File.join(gopath, 'src', 'gopkg.in/check.v1')
            expect(packages.last.install_path).to eq File.join(gopath, 'src', 'gopkg.in/yaml.v2')
          end
        end

        context 'when GOPATH is not configured' do
          let(:home_path) { '/some/path' }

          before do
            stub_const('ENV', 'HOME' => home_path)
          end

          it 'set the packages\' install_paths to the dependencies\' location in $HOME/go' do
            packages = subject.current_packages

            expect(packages.first.install_path).to eq File.join(home_path, 'go', 'src', 'gopkg.in/check.v1')
            expect(packages.last.install_path).to eq File.join(home_path, 'go', 'src', 'gopkg.in/yaml.v2')
          end
        end
      end
    end

    describe '.prepare_command' do
      it 'returns the correct package management command' do
        expect(described_class.prepare_command).to eq('GO111MODULE=on go mod vendor')
      end
    end

    describe '.takes_priority_over' do
      it 'returns the package manager it takes priority over' do
        expect(described_class.takes_priority_over).to eq(Go15VendorExperiment)
      end
    end
  end
end
