require "spec_helper"

module LicenseFinder
  describe CLI do
    describe "#execute!(options)" do
      before { CLI.stub(:check_for_action_items) }

      context "when the approve option is provided" do
        it "should approve the requested gem" do
          dependency = double('dependency', :name => nil)
          dependency.should_receive(:approve!)

          Dependency.stub(:find_by_name).with('foo').and_return(dependency)

          CLI.execute! approve: "foo"
        end
      end

      context "when no options are provided" do
        it "should check for action items" do
          CLI.should_receive(:check_for_action_items)
          CLI.execute!
        end
      end
    end
  end
end
