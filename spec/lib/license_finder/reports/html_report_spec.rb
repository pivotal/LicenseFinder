require "spec_helper"
require "capybara"

module LicenseFinder
  describe HtmlReport do
    describe "#to_s" do
      let(:dependency_name) { "the-name" }
      let(:dependency) do
        dep = Dependency.create name: dependency_name
        dep.apply_better_license License.find_by_name("MIT")
        dep
      end

      subject { Capybara.string(HtmlReport.new([dependency]).to_s) }

      context "when the dependency is manually approved" do
        before { dependency.approve! "the-approver", "the-approval-note" }

        it "should show approved dependencies without action items" do
          is_expected.to have_selector ".approved"
          is_expected.not_to have_selector ".action-items"
        end

        it "shows the license, approver and approval notes" do
          deps = subject.find ".dependencies"
          expect(deps).to have_content "MIT"
          expect(deps).to have_content "the-approver"
          expect(deps).to have_content "the-approval-note"
          expect(deps).to have_selector "time"
        end
      end

      context "when the dependency is whitelisted" do
        before { allow(dependency).to receive_messages(whitelisted?: true) }

        it "should show approved dependencies without action items" do
          is_expected.to have_selector ".approved"
          is_expected.not_to have_selector ".action-items"
        end

        it "shows the license" do
          deps = subject.find ".dependencies"
          expect(deps).to have_content "MIT"
        end
      end

      context "when the dependency is not approved" do
        before {
          dependency.license = License.find_by_name('GPL')
          dependency.manual_approval = nil
        }

        it "should show unapproved dependencies with action items" do
          is_expected.to have_selector ".unapproved"
          is_expected.to have_selector ".action-items li"
        end
      end

      context "when the gem has many relationships" do
        before do
          allow(dependency).to receive_messages(bundler_groups: [double(name: "foo group")],
                          parents: [double(name: "foo parent")],
                          children: [double(name: "foo child")])
        end

        it "should show the relationships" do
          is_expected.to have_text "(foo group)"
          is_expected.to have_text "#{dependency_name} is required by:"
          is_expected.to have_text "foo parent"
          is_expected.to have_text "#{dependency_name} relies on:"
          is_expected.to have_text "foo child"
        end
      end

      context "when the gem has no relationships" do
        it "should not show any relationships" do
          is_expected.not_to have_text "()"
          is_expected.not_to have_text "#{dependency_name} is required by:"
          is_expected.not_to have_text "#{dependency_name} relies on:"
        end
      end
    end
  end
end
