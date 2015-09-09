require 'spec_helper'

module LicenseFinder
  describe GoWorkspace do
    let(:logger) { double(:logger, active: nil) }
    subject { GoWorkspace.new(project_path: Pathname('/Users/pivotal/workspace/loggregator'), logger: logger) }

    describe '#current_packages' do
      let(:content) {
        '_/Users/pivotal/workspace/loggregator/src/bitbucket.org/kardianos/osext
         _/Users/pivotal/workspace/loggregator/src/deaagent
         _/Users/pivotal/workspace/loggregator/src/deaagent/deaagent
         _/Users/pivotal/workspace/loggregator/src/deaagent/domain
         _/Users/pivotal/workspace/loggregator/src/doppler
         _/Users/pivotal/workspace/loggregator/src/doppler/config
         _/Users/pivotal/workspace/loggregator/src/doppler/groupedsinks
         _/Users/pivotal/workspace/loggregator/src/doppler/groupedsinks/firehose_group
         _/Users/pivotal/workspace/loggregator/src/doppler/groupedsinks/sink_wrapper'
      }

      before do
        allow(Dir).to receive(:chdir).with(Pathname('/Users/pivotal/workspace/loggregator')) { |&block| block.call }
        allow(subject).to receive(:capture).with('go list -f "{{.ImportPath}} " ./...').and_return([content.to_s, true])
      end

      describe 'should return an array of go packages' do
        it 'provides package names' do
          packages = subject.current_packages
          first_package = packages.first
          expect(first_package.name).to eq 'bitbucket.org/kardianos/osext'
          expect(first_package.version).to eq 'unknown'
          expect(first_package.install_path).to eq '/Users/pivotal/workspace/loggregator/src/bitbucket.org/kardianos/osext'
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
