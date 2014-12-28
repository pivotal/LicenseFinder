require "spec_helper"

module LicenseFinder
  describe StatusReport do
    describe '#to_s' do
      let(:dep1) do
        dep = ManualPackage.new('gem_a', '1.0')
        dep.decide_on_license(License.find_by_name("MIT"))
        dep.whitelisted!
        dep
      end

      let(:dep2) do
        ManualPackage.new('gem_b', '2.0')
      end

      subject { described_class.new([dep2, dep1]).to_s }

      it 'generates a report with the approval status, name, version and licenses of each dependency, sorted by name' do
        is_expected.to eq("X,gem_a,1.0,MIT\n,gem_b,2.0,other\n")
      end
    end
  end
end
