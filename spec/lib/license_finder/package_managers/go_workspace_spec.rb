require 'spec_helper'

module LicenseFinder
  describe GoWorkspace do
    let(:logger) { double(:logger) }
    subject { GoWorkspace.new(project_path: Pathname('/fake/path'), logger: logger) }

    it_behaves_like 'a PackageManager'

    describe '#current_packages' do
      let(:content) {
        'github.com/cloudfoundry/loggregator/src/bitbucket.org/kardianos/osext
        github.com/cloudfoundry/loggregator/src/deaagent
        github.com/cloudfoundry/loggregator/src/deaagent/deaagent
        github.com/cloudfoundry/loggregator/src/deaagent/domain
        github.com/cloudfoundry/loggregator/src/doppler
        github.com/cloudfoundry/loggregator/src/doppler/config'
      }

      before do
        allow_any_instance_of(Kernel).to receive('`').with('cd /fake/path; go list -f "{{.ImportPath}} " ./...').and_return(content.to_s)
      end

      describe 'should return an array of go packages' do
        it 'provides package names' do
          packages = subject.current_packages
          expect(packages.map(&:name)).to include('kardianos-osext', 'deaagent', 'deaagent-deaagent', 'deaagent-domain', 'doppler', 'doppler-config')
        end
      end
    end

    describe '#package_path' do
      it 'returns the package_path' do
        expect(subject.package_path).to eq Pathname('/fake/path/.envrc')
      end
    end
  end
end
