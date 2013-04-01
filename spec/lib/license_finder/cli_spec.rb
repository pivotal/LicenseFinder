require "spec_helper"

module LicenseFinder
  describe CLI do
    describe "#execute!(options)" do
      before { CLI.stub(:check_for_action_items) }

      context "when the approve option is provided" do
        it "should approve the requested gem" do
          dependency = double('dependency', :name => nil)
          dependency.should_receive(:approve!)

          Dependency.stub(:first).with(name: 'foo').and_return(dependency)

          CLI.execute! approve: true, dependency: 'foo'
        end
      end

      context "when the -l (--license) switch is provided" do
        it "should update the license on the requested gem" do
          dependency = double :dependency, :name => nil
          dependency.should_receive(:set_license_manually).with("foo")

          Dependency.stub(:first).with(name: "foo_gem").and_return dependency

          CLI.execute! license: "foo", dependency: 'foo_gem'
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
