module LicenseFinder
  module BundleSyncer
    extend self

    def sync!
      current_dependencies = Bundle.current_gem_dependencies
      Dependency.destroy_obsolete(current_dependencies)
    end
  end
end

