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
        expect(results.map(&:name)).to match_array %w[hammer helmet]
      end

      context 'when prepare flag is included' do
        it 'should run the prepare_projects method on the finders' do
          expect(license_finder_1).to receive(:prepare_projects)
          expect(license_finder_2).to receive(:prepare_projects)

          aggregator = LicenseAggregator.new({ prepare: true }, ['path/to/subproject-1', 'path/to/subproject-2'])
          aggregator.dependencies
        end
      end

      context 'when there are duplicates' do
        let(:license_finder_2) { double(:license_finder, acknowledged: [helmet, hammer]) }

        it 'aggregates duplicate packages by package name' do
          aggregator = LicenseAggregator.new({}, ['path/to/subproject-1', 'path/to/subproject-2'])
          results = aggregator.dependencies

          expect(results.count).to eq(2)

          expect(results[1].name).to eq('helmet')
          expect(results[1].subproject_paths[0]).to end_with('path/to/subproject-2')

          expect(results[0].name).to eq('hammer')
          expect(results[0].subproject_paths[0]).to end_with('path/to/subproject-1')
          expect(results[0].subproject_paths[1]).to end_with('path/to/subproject-2')
        end
      end

      context 'when there are duplicate packages with different versions' do
        let(:hammer_new) { Package.new('hammer', '2.0.0') }
        let(:license_finder_2) { double(:license_finder, acknowledged: [helmet, hammer_new]) }

        it 'does not aggregate packages with different versions' do
          aggregator = LicenseAggregator.new({}, ['path/to/subproject-1', 'path/to/subproject-2'])
          results = aggregator.dependencies

          expect(results.count).to eq(3)
          expect(results.map(&:name)).to match_array %w[hammer helmet hammer]
          expect(find_package(results, 'hammer', '1.0.0').subproject_paths[0]).to end_with('path/to/subproject-1')
          expect(find_package(results, 'hammer', '2.0.0').subproject_paths[0]).to end_with('path/to/subproject-2')
          expect(find_package(results, 'helmet', '3.0.0').subproject_paths[0]).to end_with('path/to/subproject-2')
        end
      end

      def find_package(packages, name, version)
        packages.find { |dep| dep.name == name && dep.version == version }
      end
    end
  end
end
