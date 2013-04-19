module LicenseFinder
  module BundleSyncer
    extend self

    def sync!
      current_gems = Bundle.current_gems
      current_dependencies = current_gems.map(&:save_or_merge)
      DependencyManager.clean_bundler_dependencies(current_dependencies)
    end
  end
end

