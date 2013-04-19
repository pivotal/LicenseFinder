require "spec_helper"

module LicenseFinder
  describe BundleSyncer do
    describe "#sync!" do
      it "saves new, updates old, and destroys obsolete gems" do
        current_dependencies = stub
        Bundle.stub(:current_gem_dependencies).and_return { current_dependencies }
        DependencyManager.should_receive(:clean_bundler_dependencies).with(current_dependencies)

        BundleSyncer.sync!
      end
    end
  end
end

