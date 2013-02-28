require "spec_helper"

module LicenseFinder
  describe SourceSyncer do
    it "deletes any dependencies no longer in the source" do
      foo_dep     = double :foo, name: "foo"

      foo_dep.should_receive(:destroy)

      SourceSyncer.new([], [foo_dep]).sync!
    end

    it "merges any dependencies in the source" do
      source_foo  = double :source_foo, name: "foo"
      foo = double :foo, name: "foo"

      foo.should_receive(:merge).with source_foo

      SourceSyncer.new([source_foo], [foo]).sync!
    end

    it "does not merge any dependencies that are set to manual" do
      source_foo  = double :source_foo, name: "foo"
      foo = double :foo, name: "foo", manual: true
      foo.stub(:instance_variable_get) { |ivar| true if ivar == '@manual' }

      foo.should_not_receive(:merge).with source_foo

      SourceSyncer.new([source_foo], [foo]).sync!
    end

    it "creates any new source dependencies" do
      source_dep = double :source_dep, name: "foo", attributes: double(:attributes)

      source_dep.should_receive :save

      SourceSyncer.new([source_dep], []).sync!
    end

    it "returns the synced dependency set" do
      source_dep = double(:source_dep, name: "source_dep", attributes: double(:attributes)).as_null_object
      existing_dep = double :existing_dep, name: "existing", merge: nil

      SourceSyncer.new([source_dep, existing_dep], [existing_dep]).sync!.should =~ [source_dep, existing_dep]
    end
  end
end
