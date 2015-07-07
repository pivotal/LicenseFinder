require 'spec_helper'

module LicenseFinder
  describe GoWorkspace do
    let(:logger) { double(:logger) }
    subject { GoWorkspace.new(project_path: Pathname('/Users/pivotal/workspace/loggregator'), logger: logger) }

    it_behaves_like 'a PackageManager'

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
        allow_any_instance_of(Kernel).to receive('`').with('cd /Users/pivotal/workspace/loggregator; go list -f "{{.ImportPath}} " ./...').and_return(content.to_s)
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
  end
end
