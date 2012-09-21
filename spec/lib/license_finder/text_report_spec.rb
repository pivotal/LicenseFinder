require "spec_helper"

module LicenseFinder
  describe TextReport do
    describe '#to_s' do
      let(:dep1) do
        Dependency.new(
          'name' => 'gem_a',
          'version' => '1.0',
          'license' => "MIT"
        )
      end

      let(:dep2) do
        Dependency.new(
          'name' => 'gem_b',
          'version' => '1.0',
          'license' => "MIT"
        )
      end

      subject { TextReport.new([dep2, dep1]).to_s }

      it 'should generate a text report with the name, version, and license of each dependency, sorted by name' do
        should == "gem_a, 1.0, MIT\ngem_b, 1.0, MIT"
      end
    end
  end
end
