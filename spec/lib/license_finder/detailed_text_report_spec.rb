require "spec_helper"

module LicenseFinder
  describe DetailedTextReport do
    describe '#to_s' do
      let(:dep1) do
        dependency = Dependency.new(
          'name' => 'gem_a',
          'version' => '1.0',
          'summary' => 'Summary',
          'description' => 'Description'
        )
        dependency.license = LicenseFinder::LicenseAlias.create(name: 'MIT')
        dependency
      end

      let(:dep2) do
        dependency = Dependency.new(
          'name' => 'gem_b',
          'version' => '1.0',
          'summary' => 'Summary',
          'description' => 'Description'
        )
        dependency.license = LicenseFinder::LicenseAlias.create(name: 'MIT')
        dependency
      end

      subject { DetailedTextReport.new([dep2, dep1]).to_s }

      it 'should generate a text report with the name, version, license, summary and description of each dependency, sorted by name' do
        should == "gem_a,1.0,MIT,Summary,Description\ngem_b,1.0,MIT,Summary,Description\n"
      end
    end
  end
end
