module LicenseFinder
  module BundleSyncer
    extend self

    def sync!
      current_dependencies = Bundle.new.gems.map(&:to_dependency)
      prior_dependencies = Dependency.all
      SourceSyncer.new(current_dependencies, prior_dependencies).sync!
    end
  end
end

