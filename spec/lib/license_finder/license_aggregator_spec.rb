# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe LicenseAggregator do
    let(:configuration) { LicenseFinder::Configuration.new({}, {}) }

    context 'when there are no packages' do
      describe '#any_packages' do
        let(:project_1_path) { 'path/to/subproject-1' }
        let(:license_finder_1) { double(:license_finder, acknowledged: [], project_path: project_1_path, any_packages?: false) }
        it 'should return false' do
          allow(Core).to receive(:new).and_return(license_finder_1)
          expect(described_class.new(configuration, [project_1_path]).any_packages?).to be_falsey
        end
      end
    end

    context 'when no duplicates' do
      let(:hammer) { Package.new('hammer', '1.0.0') }
      let(:helmet) { Package.new('helmet', '3.0.0') }
      let(:project_1_path) { 'path/to/subproject-1' }
      let(:project_2_path) { 'path/to/subproject-2' }
      let(:license_finder_1) { double(:license_finder, acknowledged: [hammer], project_path: project_1_path, any_packages?: true) }
      let(:license_finder_2) { double(:license_finder, acknowledged: [helmet], project_path: project_2_path, any_packages?: true) }
      before do
        allow(Core).to receive(:new).and_return(license_finder_1, license_finder_2)
      end
      describe '#any_packages?' do
        it 'should return true' do
          expect(described_class.new(configuration, [project_1_path, project_2_path]).any_packages?).to be_truthy
        end
      end

      describe '#unapproved' do
        let(:merged_1_expected) { MergedPackage.new(hammer, [project_1_path]) }
        let(:merged_2_expected) { MergedPackage.new(helmet, [project_2_path]) }
        it 'should return list of unapproved packages' do
          aggregator = described_class.new(configuration, [project_1_path, project_2_path])
          expect(aggregator.unapproved).to eq([merged_1_expected, merged_2_expected])
        end
      end

      describe '#blacklisted' do
        before do
          hammer.blacklisted!
        end
        let(:merged_1_expected) { MergedPackage.new(hammer, [project_1_path]) }
        it 'should return list of blacklisted packages' do
          aggregator = described_class.new(configuration, [project_1_path, project_2_path])
          expect(aggregator.blacklisted).to eq([merged_1_expected])
        end
      end
    end

    context 'when duplicates' do
      let(:hammer) { Package.new('hammer', '1.0.0') }
      let(:helmet) { Package.new('helmet', '3.0.0') }
      let(:project_1_path) { 'path/to/subproject-1' }
      let(:project_2_path) { 'path/to/subproject-2' }
      let(:license_finder_1) { double(:license_finder, acknowledged: [hammer], project_path: project_1_path, any_packages?: true) }
      let(:license_finder_2) { double(:license_finder, acknowledged: [hammer, helmet], project_path: project_2_path, any_packages?: true) }
      before do
        allow(Core).to receive(:new).and_return(license_finder_1, license_finder_2)
      end

      describe '#any_packages?' do
        it 'should return true' do
          expect(described_class.new(configuration, [project_1_path, project_2_path]).any_packages?).to be_truthy
        end
      end

      describe '#unapproved' do
        let(:merged_1_expected) { MergedPackage.new(hammer, [project_1_path, project_2_path]) }
        let(:merged_2_expected) { MergedPackage.new(helmet, [project_2_path]) }
        it 'should return list of unapproved packages' do
          aggregator = described_class.new(configuration, [project_1_path, project_2_path])
          expect(aggregator.unapproved).to eq([merged_1_expected, merged_2_expected])
        end
      end

      describe '#blacklisted' do
        before do
          hammer.blacklisted!
        end
        let(:merged_1_expected) { MergedPackage.new(hammer, [project_1_path, project_2_path]) }
        it 'should return list of blacklisted packages' do
          aggregator = described_class.new(configuration, [project_1_path, project_2_path])
          expect(aggregator.blacklisted).to eq([merged_1_expected])
        end
      end
    end

    context 'when duplicates with different versions' do
      let(:hammer1) { Package.new('hammer', '1.0.0') }
      let(:hammer2) { Package.new('hammer', '3.0.0') }
      let(:project_1_path) { 'path/to/subproject-1' }
      let(:project_2_path) { 'path/to/subproject-2' }
      let(:license_finder_1) { double(:license_finder, acknowledged: [hammer1], project_path: project_1_path, any_packages?: true) }
      let(:license_finder_2) { double(:license_finder, acknowledged: [hammer1, hammer2], project_path: project_2_path, any_packages?: true) }

      before do
        allow(Core).to receive(:new).and_return(license_finder_1, license_finder_2)
      end
      describe '#any_packages?' do
        it 'should return true' do
          expect(described_class.new(configuration, [project_1_path, project_2_path]).any_packages?).to be_truthy
        end
      end

      describe '#unapproved' do
        let(:merged_1_expected) { MergedPackage.new(hammer1, [project_1_path, project_2_path]) }
        let(:merged_2_expected) { MergedPackage.new(hammer2, [project_2_path]) }
        it 'should return list of unapproved packages' do
          aggregator = described_class.new(configuration, [project_1_path, project_2_path])
          expect(aggregator.unapproved).to eq([merged_1_expected, merged_2_expected])
        end
      end

      describe '#blacklisted' do
        before do
          hammer1.blacklisted!
        end
        let(:merged_1_expected) { MergedPackage.new(hammer1, [project_1_path, project_2_path]) }
        it 'should return list of blacklisted packages' do
          aggregator = described_class.new(configuration, [project_1_path, project_2_path])
          expect(aggregator.blacklisted).to eq([merged_1_expected])
        end
      end
    end

    describe '#dependencies' do
      let(:hammer) { Package.new('hammer', '1.0.0') }
      let(:helmet) { Package.new('helmet', '3.0.0') }
      let(:project_1_path) { 'path/to/subproject-1' }
      let(:project_2_path) { 'path/to/subproject-2' }
      let(:license_finder_1) { double(:license_finder, acknowledged: [hammer], project_path: project_1_path) }
      let(:license_finder_2) { double(:license_finder, acknowledged: [helmet], project_path: project_2_path) }

      before do
        allow(Core).to receive(:new).and_return(license_finder_1, license_finder_2)
      end

      it 'returns an array of MergedPackage objects' do
        aggregator = LicenseAggregator.new(configuration, ['path/to/subproject-1', 'path/to/subproject-2'])
        results = aggregator.dependencies
        expect(results.first).to be_a(MergedPackage)
        expect(results.map(&:name)).to match_array %w[hammer helmet]
      end

      context 'when prepare flag is included' do
        it 'should run the prepare_projects method on the finders' do
          expect(license_finder_1).to receive(:prepare_projects)
          expect(license_finder_2).to receive(:prepare_projects)
          allow(configuration).to receive(:prepare).and_return(true)
          aggregator = LicenseAggregator.new(configuration, ['path/to/subproject-1', 'path/to/subproject-2'])
          aggregator.dependencies
        end
      end

      context 'when there are duplicates' do
        let(:license_finder_2) { double(:license_finder, acknowledged: [helmet, hammer], project_path: project_2_path) }

        it 'aggregates duplicate packages by package name' do
          aggregator = LicenseAggregator.new(configuration, ['path/to/subproject-1', 'path/to/subproject-2'])
          results = aggregator.dependencies

          expect(results.count).to eq(2)

          expect(results[1].name).to eq('helmet')
          expect(results[1].aggregate_paths[0]).to end_with('path/to/subproject-2')

          expect(results[0].name).to eq('hammer')
          expect(results[0].aggregate_paths[0]).to end_with('path/to/subproject-1')
          expect(results[0].aggregate_paths[1]).to end_with('path/to/subproject-2')
        end
      end

      context 'when there are duplicate packages with different versions' do
        let(:hammer_new) { Package.new('hammer', '2.0.0') }
        let(:license_finder_2) { double(:license_finder, acknowledged: [helmet, hammer_new], project_path: project_2_path) }

        it 'does not aggregate packages with different versions' do
          aggregator = LicenseAggregator.new(configuration, ['path/to/subproject-1', 'path/to/subproject-2'])
          results = aggregator.dependencies

          expect(results.count).to eq(3)
          expect(results.map(&:name)).to match_array %w[hammer helmet hammer]
          expect(find_package(results, 'hammer', '1.0.0').aggregate_paths[0]).to end_with('path/to/subproject-1')
          expect(find_package(results, 'hammer', '2.0.0').aggregate_paths[0]).to end_with('path/to/subproject-2')
          expect(find_package(results, 'helmet', '3.0.0').aggregate_paths[0]).to end_with('path/to/subproject-2')
        end
      end

      def find_package(packages, name, version)
        packages.find { |dep| dep.name == name && dep.version == version }
      end
    end
  end
end
