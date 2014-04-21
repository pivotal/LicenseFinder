require "bundler"

module LicenseFinder
  class Bundler
    class << self
      def current_packages(ignore_groups = LicenseFinder.config.ignore_groups, bundler_definition=nil)
        new(ignore_groups, bundler_definition).packages
      end

      def active?
        gemfile_path.exist?
      end

      def gemfile_path
        Pathname.new("Gemfile").expand_path
      end
    end

    def initialize(ignore_groups, bundler_definition=nil)
      @definition = bundler_definition || ::Bundler::Definition.build(self.class.gemfile_path, lockfile_path, nil)
      @ignore_groups = ignore_groups
    end

    def packages
      top_level_gems = Set.new

      packages = definition.specs_for(included_groups).map do |gem_def|
        bundler_def = bundler_defs.detect { |bundler_def| bundler_def.name == gem_def.name }

        top_level_gems << format_name(gem_def)

        BundlerPackage.new(gem_def, bundler_def)
      end

      packages.each do |gem|
        gem.children = children_for(gem, top_level_gems)
      end

      packages
    end

    private
    attr_reader :definition, :ignore_groups

    def bundler_defs
      @bundler_defs ||= definition.dependencies
    end

    def included_groups
      definition.groups - ignore_groups.map(&:to_sym)
    end

    def lockfile_path
      self.class.gemfile_path.dirname.join('Gemfile.lock')
    end

    def children_for(gem, top_level_gems)
      gem.gem_def.dependencies.map(&:name).select { |name| top_level_gems.include? name }
    end

    def format_name(gem)
      gem.name.split(" ")[0]
    end
  end
end
