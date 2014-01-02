require "spec_helper"

module LicenseFinder
  describe MarkdownReport do
    describe '#to_s' do
      let(:dep1) do
        dependency = Dependency.new(
          'name' => 'gem_a',
          'version' => '1.0'
        )
        dependency.license = LicenseFinder::LicenseAlias.create(name: 'MIT')
        dependency.approval = Approval.create(state: false)
        dependency
      end

      let(:dep2) do
        dependency = Dependency.new(
          'name' => 'gem_b',
          'version' => '2.3'
        )
        dependency.license = LicenseFinder::LicenseAlias.create(name: 'BSD')
        dependency.approval = Approval.create(state: true)
        dependency
      end

      subject { MarkdownReport.new([dep2, dep1]).to_s }

      it 'should have the correct header' do
        LicenseFinder.config.project_name = "new_project_name"
        should match "# new_project_name"
      end

      it 'should list the total, and unapproved counts' do
        should match "2 total, _1 unapproved_"
      end

      it "should list the unapproved dependency" do
        should match "href='#gem_a'"
      end

      it "should display a summary" do
        should match "## Summary"
        should match /\s+\* 1 MIT/
        should match /\s+\* 1 BSD/
      end

      it "should list both gems" do
        should match "## Items"
        should match "### gem_a v1.0"
        should match "### gem_b v2.3"
      end
    end
  end
end
