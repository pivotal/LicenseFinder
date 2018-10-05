# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe TextReport do
    describe '#to_s' do
      let(:dep1) do
        result = Package.new('gem_a', '1.0')
        result.decide_on_license(License.find_by_name('MIT'))
        result
      end

      let(:dep2) do
        result = Package.new('gem_b', '1.0')
        result.decide_on_license(License.find_by_name('MIT'))
        result
      end

      let(:dep3) do
        result = Package.new('gem_c', '2.0')
        result.decide_on_license(License.find_by_name('MIT'))
        result.decide_on_license(License.find_by_name('BSD'))
        result
      end

      subject { described_class.new([dep3, dep2, dep1]).to_s }

      it 'should generate a text report with the name, version and license of each dependency, sorted by name' do
        is_expected.to eq("gem_a, 1.0, MIT\ngem_b, 1.0, MIT\ngem_c, 2.0, \"MIT, BSD\"\n")
      end

      it 'should generate a text report with the name, version of each dependency, use --columns option' do
        report = described_class.new([dep3, dep2, dep1], columns: %w[name version]).to_s
        expect(report).to eq("gem_a, 1.0\ngem_b, 1.0\ngem_c, 2.0\n")
      end

      it 'prints a warning message for packages that have not been installed' do
        dep = Package.new('gem_d', '2.0', missing: true)
        report = described_class.new([dep]).to_s
        expect(report).to eq("gem_d, 2.0, \"This package is not installed. Please install to determine licenses.\"\n")
      end
    end
  end
end
