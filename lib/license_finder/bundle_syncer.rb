module LicenseFinder
  module BundleSyncer
    extend self

    def sync!
      dependency_list = DependencyList.from_bundler(Bundle.new)

      if File.exists?(LicenseFinder.config.dependencies_yaml)
        yml = File.read(LicenseFinder.config.dependencies_yaml)
        existing_list = DependencyList.new Dependency.all
        dependency_list = existing_list.merge(dependency_list)
      end

      dependency_list.dependencies.map(&:save)
    end
  end
end

