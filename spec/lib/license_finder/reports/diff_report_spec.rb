require 'spec_helper'

module LicenseFinder
  describe DiffReport do
    describe '#to_s' do
      it 'should generate a diff report' do
        foo = Package.new('foo', '1.0.0', spec_licenses: ['MIT'])
        foo.status = 'added'

        bar = Package.new('bar', '1.1.0', spec_licenses: ['GPLv2'])
        bar.status = 'removed'

        report = DiffReport.new([foo, bar])
        expect(report.to_s).to include('removed,bar,1.1.0,GPLv2')
        expect(report.to_s).to include('added,foo,1.0.0,MIT')
      end
    end
  end
end