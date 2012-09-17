require "spec_helper"

module LicenseFinder
  describe CLI do
    describe "#execute!(options)" do
      before { stub(CLI).check_for_action_items }

      context "when the approve option is provided" do
        it "should approve the requested gem" do
          dependency = Object.new

          mock(dependency).approve!
          stub(dependency).name

          mock(Dependency).find_by_name("foo") { dependency }

          CLI.execute! approve: "foo"
        end
      end

      context "when no options are provided" do
        it "should check for action items" do
          mock(CLI).check_for_action_items
          CLI.execute!
        end
      end
    end
  end
end
