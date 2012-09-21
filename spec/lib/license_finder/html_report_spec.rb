require "spec_helper"

module LicenseFinder
  describe HtmlReport do
    describe "#to_s" do
      let(:dependency) { Dependency.new 'approved' => true }
      subject { HtmlReport.new([dependency]).to_s }

      context "when the dependency is approved" do
        it "should add an approved class to dependency's container" do
          should include %{class="approved"}
        end
      end

      context "when the dependency is not approved" do
        before { dependency.approved = false }

        it "should not add an approved class to he dependency's container" do
          should include %{class="unapproved"}
        end
      end

      context "when the gem has at least one bundler group" do
        before { dependency.bundler_groups = ["group"] }
        it "should show the bundler group(s) in parens" do
          should include "(group)"
        end
      end

      context "when the gem has no bundler groups" do
        before { dependency.bundler_groups = [] }

        it "should not show any parens or bundler group info" do
          should_not include "()"
        end

      end

      context "when the gem has at least one parent" do
        before { dependency.parents = [OpenStruct.new(:name => "foo parent")] }
        it "should include a parents section" do
          should include "Parents"
        end
      end

      context "when the gem has no parents" do
        it "should not include any parents section in the output" do
          should_not include "Parents"
        end
      end

      context "when the gem has at least one child" do
        before { dependency.children = [OpenStruct.new(:name => "foo child")] }

        it "should include a Children section" do
          should include "Children"
        end
      end

      context "when the gem has no children" do
        it "should not include any Children section in the output" do
          should_not include "Children"
        end
      end
    end
  end
end
