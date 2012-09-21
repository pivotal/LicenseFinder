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

    it "creates any new source dependencies" do
      source_dep = double :source_dep, name: "foo", attributes: double(:attributes)
      new_dep = double :new_dep
      Dependency.should_receive(:new).with(source_dep.attributes).and_return new_dep
      new_dep.should_receive(:save)

      SourceSyncer.new([source_dep], []).sync!
    end
  end
end

