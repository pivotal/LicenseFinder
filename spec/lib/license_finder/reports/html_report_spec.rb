require "spec_helper"
require "capybara"

module LicenseFinder
  describe HtmlReport do
    describe "#to_s" do
      let(:dependency_name) { "the-name" }
      let(:dependency) do
        dep = Dependency.create name: dependency_name
        dep.set_licenses [License.find_by_name("MIT")]
        dep
      end

      subject { Capybara.string(HtmlReport.new([dependency]).to_s) }

      context "when the dependency is manually approved" do
        before { dependency.approve! "the-approver", "the-approval-note" }

        it "should show approved dependencies without action items" do
          should have_selector ".approved"
          should_not have_selector ".action-items"
        end

        it "shows the license, approver and approval notes" do
          deps = subject.find ".dependencies"
          deps.should have_content "MIT"
          deps.should have_content "the-approver"
          deps.should have_content "the-approval-note"
          deps.should have_selector "time"
        end
      end

      context "when the dependency is whitelisted" do
        before { dependency.stub(whitelisted?: true) }

        it "should show approved dependencies without action items" do
          should have_selector ".approved"
          should_not have_selector ".action-items"
        end

        it "shows the license" do
          deps = subject.find ".dependencies"
          deps.should have_content "MIT"
        end
      end

      context "when the dependency is not approved" do
        before {
          dependency.licenses = [License.find_by_name('GPL')]
          dependency.manual_approval = nil
        }

        it "should show unapproved dependencies with action items" do
          should have_selector ".unapproved"
          should have_selector ".action-items li"
        end
      end

      context "when the gem has many relationships" do
        before do
          dependency.stub(bundler_groups: [double(name: "foo group")],
                          parents: [double(name: "foo parent")],
                          children: [double(name: "foo child")])
        end

        it "should show the relationships" do
          should have_text "(foo group)"
          should have_text "#{dependency_name} is required by:"
          should have_text "foo parent"
          should have_text "#{dependency_name} relies on:"
          should have_text "foo child"
        end
      end

      context "when the gem has no relationships" do
        it "should not show any relationships" do
          should_not have_text "()"
          should_not have_text "#{dependency_name} is required by:"
          should_not have_text "#{dependency_name} relies on:"
        end
      end
    end
  end
end
