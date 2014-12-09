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

      subject { TextReport.new([dep3, dep2, dep1]).to_s }

      it 'should generate a text report with the name, version and license of each dependency, sorted by name' do
        is_expected.to eq("gem_a, 1.0, MIT\ngem_b, 1.0, MIT\ngem_c, 2.0, \"MIT, BSD\"\n")
      end
    end
  end
end
