require "spec_helper"

module LicenseFinder
  describe TextReport do
    describe '#to_s' do
      let(:dep1) do
        Dependency.new(
          'name' => 'gem_a',
          'version' => '1.0',
          'licenses' => [License.find_by_name('MIT')].to_set
        )
      end

      let(:dep2) do
        Dependency.new(
          'name' => 'gem_b',
          'version' => '1.0',
          'licenses' => [License.find_by_name('MIT')].to_set
        )
      end

      let(:dep3) do
        Dependency.new(
          'name' => 'gem_c',
          'version' => '2.0',
          'licenses' => [License.find_by_name('MIT'), License.find_by_name("BSD")].to_set
        )
      end

      let(:dep4) do
        Dependency.new(
            'name' => 'gem_d',
            'version' => '2.0',
            'licenses' => [License.find_by_name(nil)].to_set,
            'missing' => true
        )
      end

      it 'should generate a text report with the name, version and license of each dependency, sorted by name' do
        report = TextReport.new([dep3, dep2, dep1] ).to_s
        expect(report).to eq("gem_a, 1.0, MIT\ngem_b, 1.0, MIT\ngem_c, 2.0, \"MIT, BSD\"\n")
      end

      it 'prints a warning message for packages that have not been installed' do
        report = TextReport.new([dep3, dep4] ).to_s
        expect(report).to eq("gem_c, 2.0, \"MIT, BSD\"\ngem_d, 2.0, \"This package is not installed. Please install to determine licenses.\"\n")

      end
    end
  end
end
