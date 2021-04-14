# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe GoModules do
    it_behaves_like 'a PackageManager'

    let(:src_path) { '/workspace/code' }
    let(:mod_path) { "#{src_path}/go.mod" }
    let(:vendor_path) { "#{src_path}/vendor" }
    let(:go_list_format) { '{{ if and (.DepOnly) (not .Standard) }}{{ $mod := (or .Module.Replace .Module) }}{{ $mod.Path }},{{ $mod.Version }},{{ or $mod.Dir .Dir }}{{ end }}' }
    let(:go_list_string) do
      "foo,,/workspace/code/\ngopkg.in/check.v1,v0.0.0-20161208181325-20d25e280405,"\
"/workspace/LicenseFinder/features/fixtures/go_modules/vendor/gopkg.in/check.v1\n"\
"gopkg.in/yaml.v2,v2.2.1,/workspace/LicenseFinder/features/fixtures/go_modules/vendor/gopkg.in/yaml.v2\n"\
'gopkg.in/yaml.v2,v2.2.1,/workspace/LicenseFinder/features/fixtures/go_modules/vendor/gopkg.in/yaml.v2'
    end
    let(:logger) { double(:logger, active: nil, info: nil) }

    subject { GoModules.new(project_path: Pathname(src_path), logger: logger, log_directory: 'some-directory') }

    describe '#current_packages' do
      let(:go_list_cmd) { "GO111MODULE=on go list -mod=readonly -deps -f '#{go_list_format}' ./..." }

      before do
        FakeFS.activate!
        FileUtils.mkdir_p(vendor_path)
      end

      after do
        FakeFS.deactivate!
      end

      context 'go list is successful' do
        let(:success_status) { double(Process::Status, success?: true) }

        before do
          File.write(mod_path, content)
          allow(SharedHelpers::Cmd).to receive(:run).with(go_list_cmd).and_return([go_list_string, nil, success_status])
        end

        let(:content) do
          FakeFS.without do
            fixture_from('go.mod')
          end
        end

        it 'finds all the packages all go.mod files' do
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

        it 'sets homepage for the packages' do
          packages = subject.current_packages

          expect(packages[0].homepage).to eq('gopkg.in/check.v1')
        end
      end

      context 'go list failed' do
        let(:failure_status) { double(Process::Status, success?: false) }

        before do
          allow(SharedHelpers::Cmd).to receive(:run).with(go_list_cmd).and_return(['', 'some-error-message', failure_status])
        end

        it 'should print out the error from calling go list and raise' do
          expect(logger).to receive(:info).with(go_list_cmd, 'did not succeed.', color: :red)
          expect(logger).to receive(:info).with(go_list_cmd, "Getting the dependencies from go list failed \n\tsome-error-message", color: :red).ordered

          expect { subject.current_packages }.to raise_error("Command '#{go_list_cmd}' failed to execute")
        end
      end
    end

    describe '.takes_priority_over' do
      it 'returns the package manager it takes priority over' do
        expect(described_class.takes_priority_over).to eq(Go15VendorExperiment)
      end
    end
  end
end
