require "bundler"

module LicenseFinder
  class Bundler
    def initialize options={}
      @ignore_groups = options[:ignore_groups] # dependency injection for tests
      @definition    = options[:definition]    # dependency injection for tests
      @gemfile_path  = options[:gemfile_path]  # dependency injection for tests
    end

    def active?
      gemfile_path.exist?
    end

    def current_packages
      top_level_gems = Set.new

      packages = definition.specs_for(included_groups).map do |gem_def|
        bundler_def = bundler_defs.detect { |bundler_def| bundler_def.name == gem_def.name }

        top_level_gems << format_name(gem_def)

        BundlerPackage.new(gem_def, bundler_def)
      end

      packages.each do |package|
        package.children = children_for(package, top_level_gems)
      end

      packages
    end

    private

    def definition
      @definition ||= ::Bundler::Definition.build(gemfile_path, lockfile_path, nil)
    end

    def ignore_groups
      @ignore_groups ||= LicenseFinder.config.ignore_groups
    end

    def bundler_defs
      @bundler_defs ||= definition.dependencies
    end

    def gemfile_path
      @gemfile_path ||= Pathname.new("Gemfile").expand_path
    end

    def included_groups
      definition.groups - ignore_groups.map(&:to_sym)
    end

    def lockfile_path
      gemfile_path.dirname.join('Gemfile.lock')
    end

    def children_for(package, top_level_gems)
      package.gem_def.dependencies.map(&:name).select { |name| top_level_gems.include? name }
    end

    def format_name(gem)
      gem.name.split(" ")[0]
    end
  end
end
