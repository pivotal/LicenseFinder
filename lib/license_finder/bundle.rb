module LicenseFinder
  class Bundle
    def gems
      definition.specs_for(included_groups).map do |spec|
        dependency = dependencies.detect { |dep| dep.name == spec.name }

        BundledGem.new(spec, dependency)
      end
    end

    private

    def definition
      @definition ||= Bundler::Definition.build(gemfile_path, lockfile_path, nil)
    end

    def dependencies
      @dependencies ||= definition.dependencies
    end

    def included_groups
      definition.groups - LicenseFinder.config.ignore_groups
    end

    def gemfile_path
      Pathname.new("Gemfile").expand_path
    end

    def lockfile_path
      gemfile_path.dirname.join('Gemfile.lock')
    end
  end
end
