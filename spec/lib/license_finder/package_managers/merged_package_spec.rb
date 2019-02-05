# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe MergedPackage do
    let(:package) do
      Package.new(
        'foo', '1.0.0',
        spec_licenses: ['MIT'],
        install_path: fixture_path('nested_gem'),
        authors: 'An author',
        description: 'A description',
        summary: 'A summary',
        homepage: 'http://homepage.example.com',
        groups: %w[development production]
      )
    end

    let(:aggregate_paths) { 'path/to/project/with/foo' }

    subject { MergedPackage.new(package, [aggregate_paths]) }

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
      expect(subject.aggregate_paths.length).to eq(1)
      expect(subject.aggregate_paths[0]).to end_with(aggregate_paths)
    end

    it 'returns the install path' do
      expect(subject.install_path).to eq(package.install_path)
    end

    it 'returns the license files' do
      expect(subject.license_files.map(&:path)).to eq(package.license_files.map(&:path))
    end

    it 'returns the notice files' do
      expect(subject.notice_files.map(&:path)).to eq(package.notice_files.map(&:path))
    end

    it 'returns the homepage' do
      expect(subject.homepage).to eq('http://homepage.example.com')
    end

    it 'returns the summary' do
      expect(subject.summary).to eq('A summary')
    end

    it 'returns the authors' do
      expect(subject.authors).to eq('An author')
    end

    it 'returns the description' do
      expect(subject.description).to eq('A description')
    end

    it 'returns the groups' do
      expect(subject.groups).to eq(%w[development production])
    end

    it 'returns the package_manager' do
      expect(subject.package_manager).to eq('unknown')
    end

    describe '#eql?' do
      it 'returns false when the package names are the same, but the version is different' do
        p1 = MergedPackage.new(Package.new('foo', '1.0.0'), ['/path/to/package1'])
        p2 = MergedPackage.new(Package.new('foo', '2.0.0'), ['/path/to/package2'])
        p3 = MergedPackage.new(Package.new('bar', '1.0.0'), ['/path/to/package3'])
        expect(p1.eql?(p2)).to eq(false)
        expect(p1.eql?(p3)).not_to eq(true)
      end

      it 'can handle merged packages that contain other merged packages' do
        p1 = MergedPackage.new(Package.new('foo', '1.0.0'), ['/path/to/package1'])
        p2 = MergedPackage.new(Package.new('foo', '2.0.0'), ['/path/to/package2'])
        p3 = MergedPackage.new(p1, ['/path/to/package3', '/path/to/package1'])
        p4 = MergedPackage.new(p2, ['/path/to/package4', '/path/to/package2'])
        expect(p1.eql?(p3)).to eq(true)
        expect(p3.eql?(p1)).to eq(true)
        expect(p1.eql?(p4)).not_to eq(true)
        expect(p4.eql?(p1)).not_to eq(true)
        expect(p3.eql?(p3)).to eq(true)
      end
    end

    describe 'hash' do
      it 'returns equal hash codes for packages that are equal' do
        p1 = MergedPackage.new(Package.new('foo', '1.0.0'), ['/path/to/package1'])
        p2 = MergedPackage.new(Package.new('foo', '1.0.0'), ['/path/to/package2'])
        p3 = MergedPackage.new(Package.new('foo', '2.0.0'), ['/path/to/package3'])
        expect(p1.hash).to eq(p2.hash)
        expect(p1.hash).not_to eq(p3.hash)
      end
    end
  end
end
