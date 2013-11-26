require "bundler"

module LicenseFinder
  class Bundler
    attr_writer :ignore_groups

    class << self
      def current_packages(config = LicenseFinder.config, bundler_definition=nil)
        new(config, bundler_definition).packages
      end

      def active?
        File.exists?(gemfile_path)
      end

      def gemfile_path
        Pathname.new("Gemfile").expand_path
      end
    end

    def initialize(config, bundler_definition=nil)
      @definition = bundler_definition || ::Bundler::Definition.build(self.class.gemfile_path, lockfile_path, nil)
      @config = config
    end

    def packages
      return @packages if @packages

      top_level_gems = Set.new

      @packages ||= definition.specs_for(included_groups).map do |gem_def|
        bundler_def = bundler_defs.detect { |bundler_def| bundler_def.name == gem_def.name }

        top_level_gems << format_name(gem_def)

        BundlerPackage.new(gem_def, bundler_def)
      end

      @packages.each do |gem|
        gem.children = children_for(gem, top_level_gems)
      end

      @packages
    end

    private
    attr_reader :definition

    def ignore_groups
      @ignore_groups ||= @config.ignore_groups
    end

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
