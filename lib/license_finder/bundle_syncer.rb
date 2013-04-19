module LicenseFinder
  module BundleSyncer
    extend self

    def sync!
      current_dependencies = Bundle.current_gem_dependencies
      DependencyManager.clean_bundler_dependencies(current_dependencies)
    end
  end
end

