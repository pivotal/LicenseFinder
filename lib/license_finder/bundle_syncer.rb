module LicenseFinder
  module BundleSyncer
    extend self

    def sync!
      source_dependencies = Bundle.new.gems.map(&:to_dependency)
      target_dependencies = Dependency.all
      SourceSyncer.new(source_dependencies, target_dependencies).sync!
    end
  end
end

