module LicenseFinder
  class BundlerDependencyQuery
    def dependencies
      bundler_definition.specs_for(requested_groups).map do |spec|
        dependency = define_a_new_dependency_from_a_gemspec(spec)
        add_additional_information_from_bundler_to_a_dependency(dependency)
      end
    end

    private

    def add_additional_information_from_bundler_to_a_dependency(dependency)
      bundler_dependency = find_bundlers_representation_of_a_dependency_by_name(dependency.name)

      if bundler_dependency
        dependency.bundler_groups = bundler_dependency.groups
      end

      dependency
    end

    def define_a_new_dependency_from_a_gemspec(gemspec)
      GemSpecDetails.new(gemspec).dependency
    end

    def find_bundlers_representation_of_a_dependency_by_name(name)
      bundler_dependencies.detect { |dep| dep.name == name }
    end

    def requested_groups
      bundler_definition.groups - LicenseFinder.config.ignore_groups
    end

    def gemfile_path
      Pathname.new("Gemfile").expand_path
    end

    def lockfile_path
      root = gemfile_path.dirname
      root.join('Gemfile.lock')
    end

    def bundler_dependencies
      @bundler_dependencies ||= bundler_definition.dependencies
    end

    def bundler_definition
      @bundler_definition ||= Bundler::Definition.build(gemfile_path, lockfile_path, nil)
    end
  end
end
