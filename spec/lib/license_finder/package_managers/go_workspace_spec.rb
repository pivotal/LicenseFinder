require 'spec_helper'

module LicenseFinder
  describe GoWorkspace do
    let(:options) { {} }
    let(:logger) { double(:logger, active: nil) }
    subject { GoWorkspace.new(options.merge(project_path: Pathname('/Users/pivotal/workspace/loggregator'), logger: logger)) }

    describe '#current_packages' do
      let(:content) {
        '_/Users/pivotal/workspace/loggregator/src/bitbucket.org/kardianos/osext
         _/Users/pivotal/workspace/loggregator/src/bitbucket.org/kardianos/osext/something
         _/Users/pivotal/workspace/loggregator/src/deaagent
         _/Users/pivotal/workspace/loggregator/src/deaagent/deaagent
         _/Users/pivotal/workspace/loggregator/src/deaagent/domain
         _/Users/pivotal/workspace/loggregator/src/doppler
         _/Users/pivotal/workspace/loggregator/src/doppler/config
         _/Users/pivotal/workspace/loggregator/src/doppler/groupedsinks
         _/Users/pivotal/workspace/loggregator/src/doppler/groupedsinks/firehose_group
         _/Users/pivotal/workspace/loggregator/src/doppler/groupedsinks/sink_wrapper'
      }

      let(:git_modules) {
        "b8a35001b773c267e src/bitbucket.org/kardianos/osext (heads/master)"
      }

      before do
        allow(Dir).to receive(:chdir).with(Pathname('/Users/pivotal/workspace/loggregator')) { |&block| block.call }
        allow(subject).to receive(:capture).with('go list -f "{{.ImportPath}} " ./...').and_return([content.to_s, true])
        allow(subject).to receive(:capture).with('git submodule status').and_return([git_modules, true])
      end

      describe 'should return an array of go packages' do
        it 'provides package names' do
          packages = subject.current_packages
          first_package = packages.first
          expect(first_package.name).to eq 'bitbucket.org/kardianos/osext'
          expect(first_package.version).to eq 'b8a3500'
          expect(first_package.install_path).to eq '/Users/pivotal/workspace/loggregator/src/bitbucket.org/kardianos/osext'
        end

        it 'should filter the subpackages' do
          packages = subject.current_packages
          packages = packages.select { |p| p.name.include?("bitbucket.org") }
          expect(packages.count).to eq(1)
        end

        context 'if git submodule status fails' do
          before do
            allow(subject).to receive(:capture).with('git submodule status').and_return(['', false])
          end

          it 'should raise an exception' do
            expect { subject.current_packages }.to raise_exception(/git submodule status failed/)
          end
        end

        context 'when requesting the full version' do
          let(:options) { { go_full_version:true } }
          it 'list the dependencies with full version' do
            expect(subject.current_packages.map(&:version)).to eq ["b8a35001b773c267e"]
          end
        end
      end

      describe '#package_path' do
        it 'returns the package_path' do
          expect(subject.package_path).to eq Pathname('/Users/pivotal/workspace/loggregator/.envrc')
        end
      end

      describe '#active?' do
        let(:envrc)   { '/Users/pivotal/workspace/loggregator/.envrc' }

        it 'returns true when .envrc contains GOPATH' do
          allow(FileTest).to receive(:exist?).with(envrc).and_return(true)
          allow(IO).to receive(:read).with(Pathname(envrc)).and_return('export GOPATH=/foo/bar')
          expect(subject.active?).to eq(true)
        end

        it 'returns false when .envrc does not contain GOPATH' do
          allow(FileTest).to receive(:exist?).with(envrc).and_return(true)
          allow(IO).to receive(:read).with(Pathname(envrc)).and_return('this is not an envrc file')
          expect(subject.active?).to eq(false)
        end

        it 'returns false when .envrc does not exist' do
          allow(FileTest).to receive(:exist?).with(envrc).and_return(false)
          expect(subject.active?).to eq(false)
        end

        it 'logs the active state' do
          expect(logger).to receive(:active)
          subject.active?
        end
      end
    end
  end
end
