# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe GoWorkspace do
    let(:options) { {} }
    let(:logger) { double(:logger, debug: nil, info: nil) }
    let(:project_path) { '/Users/pivotal/workspace/loggregator' }
    subject { GoWorkspace.new(options.merge(project_path: Pathname(project_path), logger: logger)) }

    context 'package manager' do
      before do
        allow_any_instance_of(GoDep).to receive(:active?).and_return(false)
      end

      it 'installed? should be true if go exists on the path' do
        allow(PackageManager).to receive(:command_exists?).with('go').and_return true
        expect(described_class.installed?).to eq(true)
      end

      it 'installed? should be false if go does not exists on the path' do
        allow(PackageManager).to receive(:command_exists?).with('go').and_return false
        expect(described_class.installed?(logger)).to eq(false)
      end
    end

    describe '#go_list' do
      let(:go_list_output) do
        <<HERE
gopkg.in/yaml.v2
github.com/onsi/ginkgo
myblip/blop-custom
encoding/json
golang.org/x/tools/go/ast/astutil
HERE
      end

      let(:std_packages) do
        <<HERE
go/ast
blop
encoding/json
HERE
      end

      before do
        allow(Dir).to receive(:chdir).with(Pathname.new(project_path)) { |&b| b.call }
        allow(FileTest).to receive(:exist?).and_return(false)
        allow(FileTest).to receive(:exist?).with(File.join(project_path, '.envrc')).and_return(true)
        allow(SharedHelpers::Cmd).to receive(:run).with('go list -f "{{join .Deps \"\n\"}}" ./...').and_return([go_list_output, '', cmd_success])
        allow(SharedHelpers::Cmd).to receive(:run).with('go list std').and_return([std_packages, '', cmd_success])
      end

      it 'changes the directory' do
        subject.send(:go_list)

        expect(Dir).to have_received(:chdir)
      end

      it 'lists only non-standard packages' do
        packages = subject.send(:go_list)
        expect(packages.count).to eq(3)
        expect(packages).to eq(['gopkg.in/yaml.v2', 'github.com/onsi/ginkgo', 'myblip/blop-custom'])
      end

      it 'sets gopath to the envrc path' do
        allow(SharedHelpers::Cmd).to receive(:run).with('go list -f "{{join .Deps \"\n\"}}" ./...') {
          expect(ENV['GOPATH']).to be_nil
          ['', '', cmd_success]
        }

        subject.send(:go_list)
      end
    end

    describe '#git_modules' do
      before do
        allow(FileTest).to receive(:exist?).and_return(false)
        allow(FileTest).to receive(:exist?).with('/Users/pivotal/workspace/loggregator').and_return(true)
        allow(FileTest).to receive(:exist?).with('/Users/pivotal/workspace/loggregator/.envrc').and_return(true)
        allow(Dir).to receive(:chdir).with(Pathname.new('/Users/pivotal/workspace/loggregator')) { |&b| b.call }
      end

      context 'if git submodule status fails' do
        before do
          allow(SharedHelpers::Cmd).to receive(:run).with('git submodule status').and_return(['', '', cmd_failure])
        end

        it 'should raise an exception' do
          expect { subject.send(:git_modules) }.to raise_exception(/git submodule status failed/)
        end
      end

      context 'if git submodule status succeeds' do
        let(:git_submodule_status_output) do
          <<HERE
1993eafbef57be29ee8f5eb9d26a22f20ff3c207 src/github.com/GaryBoone/GoStats (heads/master)
55eb11d21d2a31a3cc93838241d04800f52e823d src/github.com/Sirupsen/logrus (v0.7.3)
HERE
        end

        before do
          allow(SharedHelpers::Cmd).to receive(:run).with('git submodule status').and_return([git_submodule_status_output, '', cmd_success])
        end

        it 'should return the filtered submodules' do
          submodules = subject.send(:git_modules)
          expect(submodules.count).to eq(2)
          expect(submodules.first.install_path).to eq('/Users/pivotal/workspace/loggregator/src/github.com/GaryBoone/GoStats')
          expect(submodules.first.revision).to eq('1993eafbef57be29ee8f5eb9d26a22f20ff3c207')
        end
      end
    end

    describe '#current_packages' do
      let(:git_modules_output) do
        [GoWorkspace::Submodule.new('/Users/pivotal/workspace/loggregator/src/bitbucket.org/kardianos/osext', 'b8a35001b773c267e')]
      end

      let(:go_list_output) do
        [
          'bitbucket.org/kardianos/osext',
          'bitbucket.org/kardianos/osext/foo'
        ]
      end

      before do
        allow(FileTest).to receive(:exist?).and_return(true)

        allow(Dir).to receive(:chdir).with(Pathname('/Users/pivotal/workspace/loggregator')) { |&block| block.call }
        allow(subject).to receive(:go_list).and_return(go_list_output)
        allow(subject).to receive(:git_modules).and_return(git_modules_output)
      end

      it 'sets homepage for the packages' do
        packages = subject.current_packages

        expect(packages[0].homepage).to eq('bitbucket.org/kardianos/osext')
      end

      describe 'should return an array of go packages' do
        it 'provides package names' do
          packages = subject.current_packages
          expect(packages.count).to eq(1)
          first_package = packages.first
          expect(first_package.name).to eq 'bitbucket.org/kardianos/osext'
          expect(first_package.version).to eq 'b8a3500'
          expect(first_package.install_path).to eq '/Users/pivotal/workspace/loggregator/src/bitbucket.org/kardianos/osext'
        end

        it 'should filter the subpackages' do
          packages = subject.current_packages
          packages = packages.select { |p| p.name.include?('bitbucket.org') }
          expect(packages.count).to eq(1)
        end

        context 'when requesting the full version' do
          let(:options) { { go_full_version: true } }
          it 'list the dependencies with full version' do
            expect(subject.current_packages.map(&:version)).to eq ['b8a35001b773c267e']
          end
        end

        context 'when the deps are in a vendor directory' do
          let(:git_modules_output) do
            [GoWorkspace::Submodule.new('/Users/pivotal/workspace/loggregator/vendor/src/bitbucket.org/kardianos/osext', 'b8a35001b773c267e')]
          end

          it 'reports the right import path' do
            expect(subject.current_packages.map(&:name)).to include('bitbucket.org/kardianos/osext')
          end

          it 'reports the right install path' do
            expect(subject.current_packages.map(&:install_path)).to include('/Users/pivotal/workspace/loggregator/vendor/src/bitbucket.org/kardianos/osext')
          end
        end

        context 'when only the subpackage is being used' do
          let(:go_list_output) do
            [
              'bitbucket.org/kardianos/osext/foo'
            ]
          end

          it 'returns the top level repo name as the import path' do
            packages = subject.current_packages
            expect(packages.map(&:name)).to eq(['bitbucket.org/kardianos/osext'])
          end
        end

        context 'when only the subpackage is being used' do
          let(:git_modules_output) do
            [GoWorkspace::Submodule.new('/Users/pivotal/workspace/loggregator/vendor/src/github.com/onsi/foo', 'e762c377b10053a8b'),
             GoWorkspace::Submodule.new('/Users/pivotal/workspace/loggregator/vendor/src/github.com/onsi/foobar', 'b8a35001b773c267e')]
          end

          let(:go_list_output) do
            [
              'github.com/onsi/foo',
              'github.com/onsi/foobar'
            ]
          end

          it 'returns the top level repo name as the import path' do
            packages = subject.current_packages
            expect(packages.map(&:name)).to eq(['github.com/onsi/foo', 'github.com/onsi/foobar'])
          end
        end
      end
    end

    describe '#detected_package_path' do
      before do
        allow(FileTest).to receive(:exist?).and_return(true)
      end

      it 'returns the detected_package_path' do
        expect(subject.detected_package_path).to eq Pathname('/Users/pivotal/workspace/loggregator')
      end
    end

    describe '#active?' do
      let(:envrc) { '/Users/pivotal/workspace/loggregator/.envrc' }

      before do
        allow(FileTest).to receive(:exist?).and_return(false)
      end

      it 'returns true when .envrc contains GOPATH' do
        allow(FileTest).to receive(:exist?).with(envrc).and_return(true)
        allow(IO).to receive(:read).with(Pathname(envrc)).and_return('export GOPATH=/foo/bar')
        expect(subject.active?).to eq(true)
      end

      it 'returns true when .envrc contains GO15VENDOREXPERIMENT' do
        allow(FileTest).to receive(:exist?).with(envrc).and_return(true)
        allow(IO).to receive(:read).with(Pathname(envrc)).and_return('export GO15VENDOREXPERIMENT=1')
        expect(subject.active?).to eq(true)
      end

      it 'returns false when .envrc does not contain GOPATH or GO15VENDOREXPERIMENT' do
        allow(FileTest).to receive(:exist?).with(envrc).and_return(true)
        allow(IO).to receive(:read).with(Pathname(envrc)).and_return('this is not an envrc file')
        expect(subject.active?).to eq(false)
      end

      it 'returns false when .envrc does not exist' do
        expect(subject.active?).to eq(false)
      end

      context 'when Godep is present' do
        let(:godeps) { '/Users/pivotal/workspace/loggregator/Godeps/Godeps.json' }

        it 'should prefer Godeps over go_workspace' do
          allow(FileTest).to receive(:exist?).with(Pathname(godeps)).and_return(true)
          expect(subject.active?).to eq(false)
        end
      end

      context 'when .envrc is present in a parent directory' do
        subject do
          GoWorkspace.new(options.merge(project_path: Pathname('/Users/pivotal/workspace/loggregator/src/github.com/foo/bar'),
                                        logger: logger))
        end

        it 'returns true' do
          allow(FileTest).to receive(:exist?).with(envrc).and_return(true)
          allow(IO).to receive(:read).with(Pathname(envrc)).and_return('export GOPATH=/foo/bar')
          expect(subject.active?).to be true
        end
      end
    end
  end
end
