require "spec_helper"
require "capybara"

module LicenseFinder
  describe HtmlReport do
    describe "#to_s" do
      let(:dependency_name) { "the-name" }
      let(:time) { Time.now.utc }
      let(:project_name) { "given project name" }

      let(:dependency) do
        dep = Package.new(dependency_name)
        dep.decide_on_license License.find_by_name("MIT")
        dep
      end
      let(:dependencies) { [dependency] }

      subject { Capybara.string(HtmlReport.new(dependencies, project_name: project_name).to_s) }

      context "when the dependency is manually approved" do
        before { dependency.approved_manually!(Decisions::TXN.new("the-approver", "the-approval-note", time)) }

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
        let(:dependency) do
          Package.new(dependency_name, nil, groups: ["foo group"])
        end

        it "should show the group" do
          is_expected.to have_text "(foo group)"
        end
      end

      context "when the gem does not have a group" do
        it "should not show the group" do
          is_expected.not_to have_text "()"
        end
      end

      context "when the gem has many relationships" do
        let(:dependencies) do
          grandparent = Package.new("foo grandparent", nil, children: ["foo parent"])
          parent      = Package.new("foo parent",      nil, children: ["foo child"])
          child       = Package.new("foo child")
          pm = PackageManager.new
          allow(pm).to receive(:current_packages) { [grandparent, parent, child] }
          pm.current_packages_with_relations
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
          is_expected.not_to have_text "#{dependency_name} is required by:"
          is_expected.not_to have_text "#{dependency_name} relies on:"
        end
      end

      context "when the project has a name" do
        it "should show the project name" do
          title = subject.find "h1"
          expect(title).to have_text "given project name"
        end
      end

      context "when the project has no name" do
        let(:project_name) { nil }

        it "should default to the directory name" do
          allow(Dir).to receive(:getwd).and_return("/path/to/a_project")
          title = subject.find "h1"
          expect(title).to have_text "a_project"
        end
      end
    end
  end
end
