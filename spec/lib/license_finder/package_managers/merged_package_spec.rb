require 'spec_helper'

module LicenseFinder
  describe MergedPackage do
    let(:package) { Package.new('foo', '1.0.0', spec_licenses: ['MIT'], install_path: '/tmp/foo') }
    let(:subproject_paths) { 'path/to/project/with/foo' }

    subject { MergedPackage.new(package, [subproject_paths]) }

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
      expect(subject.subproject_paths.length).to eq(1)
      expect(subject.subproject_paths[0]).to end_with(subproject_paths)
    end

    it 'returns the install path' do
      expect(subject.install_path).to eq('/tmp/foo')
    end

    describe '#eql?' do
      it 'returns true when the package names are equal' do
        p1 = MergedPackage.new(Package.new('foo', '1.0.0'), ['/path/to/package1'])
        p2 = MergedPackage.new(Package.new('foo', '2.0.0'), ['/path/to/package2'])
        p3 = MergedPackage.new(Package.new('bar', '1.0.0'), ['/path/to/package3'])
        expect(p1.eql?(p2)).to eq(true)
        expect(p1.eql?(p3)).not_to eq(true)
      end

      it 'can handle merged packages that contain other merged packages' do
        p1 = MergedPackage.new(Package.new('foo', '1.0.0'), ['/path/to/package1'])
        p2 = MergedPackage.new(Package.new('foo', '2.0.0'), ['/path/to/package2'])
        p3 = MergedPackage.new(p2, ['/path/to/package3', '/path/to/package2'])
        expect(p1.eql?(p3)).to eq(true)
      end
    end

    describe 'hash' do
      it 'returns equal hash codes for packages that are equal' do
        p1 = MergedPackage.new(Package.new('foo', '1.0.0'), ['/path/to/package1'])
        p2 = MergedPackage.new(Package.new('foo', '2.0.0'), ['/path/to/package2'])
        expect(p1.hash).to eq(p2.hash)
      end
    end
  end
end
