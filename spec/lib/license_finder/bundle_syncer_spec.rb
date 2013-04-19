require "spec_helper"

module LicenseFinder
  describe BundleSyncer do
    describe "#sync!" do
      it "saves new, updates old, and destroys obsolete gems" do
        current_dependencies = stub
        current_gems = stub(map: current_dependencies)
        Bundle.stub(:current_gems).and_return { current_gems }
        DependencyManager.should_receive(:clean_bundler_dependencies).with(current_dependencies)

        BundleSyncer.sync!
      end
    end
  end
end

