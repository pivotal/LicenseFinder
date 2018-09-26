# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe MergedReport do
    describe '#to_s' do
      it 'displays the path to the dependency' do
        foo = Package.new('foo', '1.0.0', spec_licenses: ['MIT'])
        bar = Package.new('bar', '2.0.0', spec_licenses: ['GPLv2'])

        merged_foo = MergedPackage.new(foo, ['path/to/foo'])
        merged_bar = MergedPackage.new(bar, ['path/to/bar'])
        expanded_foo_path = File.expand_path(merged_foo.aggregate_paths[0])
        expanded_bar_path = File.expand_path(merged_bar.aggregate_paths[0])

        report = MergedReport.new([merged_foo, merged_bar])
        expect(report.to_s).to include("foo,1.0.0,MIT,#{expanded_foo_path}")
        expect(report.to_s).to include("bar,2.0.0,GPLv2,#{expanded_bar_path}")
      end

      it 'supports license_links column' do
        dep = Package.new('gem_a', '1.0')
        mit = License.find_by_name('MIT')
        dep.decide_on_license(mit)
        subject = described_class.new([dep], columns: %w[name licenses license_links])
        expect(subject.to_s).to eq("gem_a,MIT,#{mit.url}\n")
      end
    end

    context 'when no groups are specified' do
      let(:dep) { Package.new('gem_a', '1.0') }
      subject { described_class.new([dep], columns: %w[name version groups]) }

      it 'supports a groups column' do
        expect(subject.to_s).to eq("gem_a,1.0,\"\"\n")
      end
    end

    context 'when some groups are specified' do
      let(:dep) { Package.new('gem_a', '1.0', groups: %w[development production]) }
      subject { described_class.new([dep], columns: %w[name version groups]) }

      it 'supports a groups column' do
        expect(subject.to_s).to eq("gem_a,1.0,\"development,production\"\n")
      end
    end
  end
end
