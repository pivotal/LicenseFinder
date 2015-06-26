require 'spec_helper'

module LicenseFinder
  describe GoWorkspace do
    let(:logger) { double(:logger) }
    subject { GoWorkspace.new(project_path: Pathname('/fake/path'), logger: logger) }

    it_behaves_like 'a PackageManager'

    describe '#current_packages' do

      it 'should log an error message' do
        expect(logger).to receive(:log)
        subject.current_packages
      end

      it 'should return an empty array of packages' do
        allow(logger).to receive(:log)
        expect(subject.current_packages).to be_empty
      end
    end

    describe '#package_path' do
      it 'returns the package_path' do
        expect(subject.package_path).to eq Pathname('/fake/path/.envrc')
      end
    end
  end
end
