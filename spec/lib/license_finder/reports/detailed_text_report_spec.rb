require "spec_helper"

module LicenseFinder
  describe DetailedTextReport do
    describe '#to_s' do
      let(:dep1) do
        Dependency.new(
          'name' => 'gem_a',
          'version' => '1.0',
          'summary' => 'Summary',
          'description' => 'Description',
          'licenses' => [License.find_by_name('MIT')].to_set
        )
      end

      let(:dep2) do
        Dependency.new(
          'name' => 'gem_b',
          'version' => '1.0',
          'summary' => 'Summary',
          'description' => 'Description',
          'licenses' => [License.find_by_name('MIT')].to_set
        )
      end

      subject { DetailedTextReport.new([dep2, dep1]).to_s }

      it 'should generate a text report with the name, version, license, summary and description of each dependency, sorted by name' do
        is_expected.to eq("gem_a,1.0,MIT,Summary,Description\ngem_b,1.0,MIT,Summary,Description\n")
      end
    end
  end
end
