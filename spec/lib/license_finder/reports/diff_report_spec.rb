# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe DiffReport do
    describe '#to_s' do
      context 'reports from a single project' do
        it 'should generate a diff report' do
          foo = Package.new('foo', '1.0.0', spec_licenses: ['MIT'])

          bar = Package.new('bar', '1.1.0', spec_licenses: ['GPLv2'])

          foo_change = PackageDelta.added(foo)
          bar_change = PackageDelta.removed(bar)

          report = DiffReport.new([foo_change, bar_change])
          expect(report.to_s).to include('removed,bar,1.1.0,GPLv2')
          expect(report.to_s).to include('added,foo,1.0.0,MIT')
        end

        it 'should generate a diff report displaying version changes' do
          foo_old = Package.new('foo', '1.0.0', spec_licenses: ['MIT'])

          foo_new = Package.new('foo', '1.1.0', spec_licenses: ['MIT'])

          foo = PackageDelta.unchanged(foo_new, foo_old)

          report = DiffReport.new([foo])
          expect(report.to_s).to include('unchanged,foo,1.1.0,MIT')
        end
      end

      context 'reports from projects' do
        it 'should generate a diff report displaying source path' do
          project1_foo_old = Package.new('foo', '1.0.0', spec_licenses: ['MIT'])
          project1_foo_new = Package.new('foo', '1.1.0', spec_licenses: ['MIT'])

          project1_bar_new = Package.new('bar', '1.1.0', spec_licenses: ['MIT'])
          merged_foo_old = MergedPackage.new(project1_foo_old, ['path/to/project1'])
          merged_foo_new = MergedPackage.new(project1_foo_new, ['path/to/project1'])
          merged_bar_new = MergedPackage.new(project1_bar_new, ['path/to/project1', 'path/to/project2'])

          foo = PackageDelta.unchanged(merged_foo_new, merged_foo_old)
          bar = PackageDelta.added(merged_bar_new)
          expanded_foo_path = File.expand_path(merged_foo_old.aggregate_paths[0])
          expanded_bar_path1 = File.expand_path(merged_bar_new.aggregate_paths[0])
          expanded_bar_path2 = File.expand_path(merged_bar_new.aggregate_paths[1])

          report = DiffReport.new([foo, bar])
          expect(report.to_s).to include("unchanged,foo,1.1.0,MIT,#{expanded_foo_path}")
          expect(report.to_s).to include("added,bar,1.1.0,MIT,\"#{expanded_bar_path1},#{expanded_bar_path2}\"")
        end
      end
    end
  end
end
