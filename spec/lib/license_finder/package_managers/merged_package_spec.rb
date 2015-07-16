require 'spec_helper'

module LicenseFinder
  describe MergedPackage do
    let(:package) { Package.new('foo', '1.0.0', spec_licenses: ['MIT']) }
    let(:subproject_path) { 'path/to/project/with/foo' }

    subject { MergedPackage.new(package, subproject_path) }

    it 'returns the package name' do
      expect(subject.name).to eq(package.name)
    end

    it 'returns the package version' do
      expect(subject.version).to eq(package.version)
    end

    it 'returns the package licenses' do
      expect(subject.licenses).to eq(package.licenses)
    end

    it 'returns the project path' do
      expect(subject.subproject_path).to eq(subproject_path)
    end
  end
end