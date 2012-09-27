module LicenseFinder
  class Bundle
    attr_writer :ignore_groups

    def initialize(bundler_definition=nil)
      @definition = bundler_definition || Bundler::Definition.build(gemfile_path, lockfile_path, nil)
    end

    def gems
      return @gems if @gems

      @gems ||= definition.specs_for(included_groups).map do |spec|
        dependency = dependencies.detect { |dep| dep.name == spec.name }

        BundledGem.new(spec, dependency)
      end

      setup_parent_child_relationships

      @gems
    end

    private
    attr_reader :definition

    def ignore_groups
      @ignore_groups ||= LicenseFinder.config.ignore_groups
    end

    def setup_parent_child_relationships
      dependency_index = {}

      gems.each do |dep|
        dependency_index[dep.dependency_name] = dep
      end

      gems.each do |dep|
        dep.children.each do |child_dep|
          license_finder_dependency = dependency_index[child_dep]
          license_finder_dependency.parents << dep.dependency_name if license_finder_dependency
        end
      end
    end

    def dependencies
      @dependencies ||= definition.dependencies
    end

    def included_groups
      definition.groups - ignore_groups
    end

    def gemfile_path
      Pathname.new("Gemfile").expand_path
    end

    def lockfile_path
      gemfile_path.dirname.join('Gemfile.lock')
    end
  end
end
