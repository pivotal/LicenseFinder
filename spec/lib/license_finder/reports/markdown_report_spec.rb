require "spec_helper"

module LicenseFinder
  describe MarkdownReport do
    describe '#to_s' do
      let(:dep1) do
        result = ManualPackage.new('gem_a', '1.0')
        result.decide_on_license(License.find_by_name('other'))
        result
      end

      let(:dep2) do
        result = ManualPackage.new('gem_b', '2.3')
        result.decide_on_license(License.find_by_name('BSD'))
        result.approved_manually!(double(:approval).as_null_object)
        result
      end

      subject { MarkdownReport.new([dep2, dep1], project_name: "new_project_name").to_s }

      it 'should have the correct header' do
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
