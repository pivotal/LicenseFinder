require "spec_helper"

module LicenseFinder
  describe DetailedTextReport do
    describe '#to_s' do
      let(:dep1) do
        result = ManualPackage.new('gem_a', '1.0')
        allow(result).to receive(:summary) { "Summary" }
        allow(result).to receive(:description) { "Description" }
        result.decide_on_license(License.find_by_name('MIT'))
        result
      end

      let(:dep2) do
        result = ManualPackage.new('gem_b', '1.0')
        allow(result).to receive(:summary) { "Summary" }
        allow(result).to receive(:description) { "Description" }
        result.decide_on_license(License.find_by_name('MIT'))
        result
      end

      subject { DetailedTextReport.new([dep2, dep1]).to_s }

      it 'should generate a text report with the name, version, license, summary and description of each dependency, sorted by name' do
        is_expected.to eq("gem_a,1.0,MIT,Summary,Description\ngem_b,1.0,MIT,Summary,Description\n")
      end
    end
  end
end
