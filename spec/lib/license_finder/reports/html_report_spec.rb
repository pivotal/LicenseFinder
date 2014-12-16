require "spec_helper"
require "capybara"

module LicenseFinder
  describe HtmlReport do
    describe "#to_s" do
      let(:dependency_name) { "the-name" }
      let(:time) { Time.now.utc }
      let(:dependency) do
        dep = ManualPackage.new(dependency_name)
        dep.decide_on_license License.find_by_name("MIT")
        dep
      end

      let(:dependencies) do
        [dependency]
      end

      subject { Capybara.string(HtmlReport.new(dependencies).to_s) }

      context "when the dependency is manually approved" do
        before { dependency.approved_manually!(Decisions::Approval.new("the-approver", "the-approval-note", time)) }

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
        before { dependency.whitelisted! }

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
        it "should show unapproved dependencies with action items" do
          is_expected.to have_selector ".unapproved"
          is_expected.to have_selector ".action-items li"
        end
      end

      context "when the gem has a group" do
        before do
          allow(dependency).to receive(:groups) { ["foo group"] }
        end

        it "should show the group" do
          is_expected.to have_text "(foo group)"
        end
      end

      context "when the gem has many relationships" do
        let(:decisions) { Decisions.new }
        let(:dependency_manager) do
          result = DependencyManager.new(decisions: decisions)
          allow(result).to receive(:current_packages) { [] }
          result
        end

        let(:dependencies) do
          dependency_manager.acknowledged
        end

        before do
          decisions.add_package("foo grandparent", nil)
          decisions.add_package("foo parent", nil)
          decisions.add_package("foo child", nil)
          grandparent, parent = decisions.packages.to_a
          allow(grandparent).to receive(:children) { ["foo parent"] }
          allow(parent).to receive(:children) { ["foo child"] }
        end

        it "should show the relationships" do
          is_expected.to have_text "foo parent is required by:"
          is_expected.to have_text "foo grandparent"
          is_expected.to have_text "foo parent relies on:"
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
