require 'spec_helper'

module LicenseFinder
  describe DiffReport do
    describe '#to_s' do
      it 'should generate a diff report' do
        foo = Package.new('foo', '1.0.0', spec_licenses: ['MIT'])

        bar = Package.new('bar', '1.1.0', spec_licenses: ['GPLv2'])

        foo_change = PackageDelta.added(foo)
        bar_change = PackageDelta.removed(bar)

        report = DiffReport.new([foo_change, bar_change])
        expect(report.to_s).to include('removed,bar,,1.1.0,GPLv2')
        expect(report.to_s).to include('added,foo,1.0.0,,MIT')
        end

      it 'should generate a diff report displaying version changes' do
        foo_old = Package.new('foo', '1.0.0', spec_licenses: ['MIT'])

        foo_new = Package.new('foo', '1.1.0', spec_licenses: ['MIT'])

        foo = PackageDelta.unchanged(foo_new, foo_old)

        report = DiffReport.new([foo])
        expect(report.to_s).to include('unchanged,foo,1.1.0,1.0.0,MIT')
      end
    end
  end
end