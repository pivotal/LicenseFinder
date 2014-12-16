require "spec_helper"

module LicenseFinder
  describe TextReport do
    describe '#to_s' do
      let(:dep1) do
        result = ManualPackage.new('gem_a', '1.0')
        result.decide_on_license(License.find_by_name('MIT'))
        result
      end

      let(:dep2) do
        result = ManualPackage.new('gem_b', '1.0')
        result.decide_on_license(License.find_by_name('MIT'))
        result
      end

      let(:dep3) do
        result = ManualPackage.new('gem_c', '2.0')
        result.decide_on_license(License.find_by_name('MIT'))
        result.decide_on_license(License.find_by_name('BSD'))
        result
      end

      subject { TextReport.new([dep3, dep2, dep1]).to_s }

      it 'should generate a text report with the name, version and license of each dependency, sorted by name' do
        is_expected.to eq("gem_a, 1.0, MIT\ngem_b, 1.0, MIT\ngem_c, 2.0, \"MIT, BSD\"\n")
      end
    end
  end
end
