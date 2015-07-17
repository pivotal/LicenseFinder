require 'spec_helper'

module LicenseFinder
  describe MergedReport do
    describe '#to_s' do
      it 'displays the path to the dependency' do
        foo = Package.new('foo', '1.0.0', spec_licenses: ['MIT'])
        bar = Package.new('bar', '2.0.0', spec_licenses: ['GPLv2'])

        merged_foo = MergedPackage.new(foo, ['path/to/foo'])
        merged_bar = MergedPackage.new(bar, ['path/to/bar'])
        expanded_foo_path = File.expand_path(merged_foo.subproject_paths[0])
        expanded_bar_path = File.expand_path(merged_bar.subproject_paths[0])

        report = MergedReport.new([merged_foo, merged_bar])
        expect(report.to_s).to include("foo,1.0.0,MIT,#{expanded_foo_path}")
        expect(report.to_s).to include("bar,2.0.0,GPLv2,#{expanded_bar_path}")
      end
    end
  end
end
