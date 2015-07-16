require 'spec_helper'

module LicenseFinder
  describe LicenseAggregator do
    describe '#dependencies' do
      let(:hammer) { Package.new('hammer', '1.0.0') }
      let(:helmet) { Package.new('helmet', '3.0.0') }
      let(:license_finder_1) { double(:license_finder, acknowledged: [hammer]) }
      let(:license_finder_2) { double(:license_finder, acknowledged: [helmet]) }

      before do
        allow(Core).to receive(:new).and_return(license_finder_1, license_finder_2)
      end

      it 'returns an array of MergedPackage objects' do
        aggregator = LicenseAggregator.new({}, ['path/to/subproject-1', 'path/to/subproject-2'])
        results = aggregator.dependencies
        expect(results.first).to be_a(MergedPackage)
        expect(results.map(&:name)).to match_array ['hammer', 'helmet']
      end
    end
  end
end