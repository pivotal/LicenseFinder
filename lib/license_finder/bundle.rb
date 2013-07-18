require "bundler"

module LicenseFinder
  class Bundle
    attr_writer :ignore_groups

    def self.current_gems(config, bundler_definition=nil)
      new(config, bundler_definition).gems
    end

    def initialize(config=nil, bundler_definition=nil)
      @definition = bundler_definition || Bundler::Definition.build(gemfile_path, lockfile_path, nil)
      @config ||= config
    end

    def gems
      return @gems if @gems

      gem_names_cache = {}

      @gems ||= definition.specs_for(included_groups).map do |spec|
        dependency = dependencies.detect { |dep| dep.name == spec.name }

        formatted_name = format_name(spec)
        gem_names_cache[format_name(spec)] = true

        BundledGem.new(spec, dependency)
      end

      @gems.each do |gem|
        gem.children = children_for(gem, gem_names_cache)
      end

      @gems
    end

    private
    attr_reader :definition

    def ignore_groups
      @ignore_groups ||= @config.ignore_groups
    end

    def dependencies
      @dependencies ||= definition.dependencies
    end

    def included_groups
      definition.groups - ignore_groups.map(&:to_sym)
    end

    def gemfile_path
      Pathname.new("Gemfile").expand_path
    end

    def lockfile_path
      gemfile_path.dirname.join('Gemfile.lock')
    end

    def children_for(gem, cache)
      gem.spec.dependencies.map(&:name).select { |name| cache[name] }
    end

    def format_name(gem)
      gem.name.split(" ")[0]
    end
  end
end
