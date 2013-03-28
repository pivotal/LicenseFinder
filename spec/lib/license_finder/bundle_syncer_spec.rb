require "spec_helper"

module LicenseFinder
  describe BundleSyncer do
    describe "#sync!" do
      it "should delegate the bundled dependencies and the persisted bundled dependencies to the source syncer" do
        gem = double :gem, :to_dependency => double(:gem_dependency)
        bundled_dep = double :bundled_dep, source: "bundle"
        syncer = double :source_syncer

        Bundle.stub_chain(:new, :gems).and_return [gem]
        Dependency.stub(:all).and_return [bundled_dep]
        SourceSyncer.should_receive(:new).with([gem.to_dependency], [bundled_dep]).and_return syncer
        syncer.should_receive(:sync!)

        BundleSyncer.sync!
      end
    end
  end
end

