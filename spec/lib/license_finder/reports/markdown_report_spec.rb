require "spec_helper"

module LicenseFinder
  describe MarkdownReport do
    describe '#to_s' do
      let(:dep1) do
        Dependency.new(
          'name' => 'gem_a',
          'version' => '1.0',
          'licenses' => [License.find_by_name('other')]
        )
      end

      let(:dep2) do
        dependency = Dependency.create(
          'name' => 'gem_b',
          'version' => '2.3',
          'licenses' => [License.find_by_name('BSD')]
        )
        dependency.approve!
        dependency
      end

      subject { MarkdownReport.new([dep2, dep1]).to_s }

      it 'should have the correct header' do
        LicenseFinder.config.project_name = "new_project_name"
        is_expected.to match "# new_project_name"
      end

      it 'should list the total, and unapproved counts' do
        is_expected.to match "2 total"
        is_expected.to match /1 \*unapproved\*/
      end

      it "should list the unapproved dependency" do
        is_expected.to match "href='#gem_a'"
      end

      it "should display a summary" do
        is_expected.to match "## Summary"
        is_expected.to match /\s+\* 1 other/
        is_expected.to match /\s+\* 1 BSD/
      end

      it "should list both gems" do
        is_expected.to match "## Items"
        is_expected.to match "### gem_a v1.0"
        is_expected.to match "### gem_b v2.3"
      end
    end
  end
end
