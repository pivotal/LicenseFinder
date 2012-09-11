module LicenseFinder
  class DependencyList

    attr_reader :dependencies

    def self.from_bundler
      gemfile = Pathname.new("Gemfile").expand_path
      root = gemfile.dirname
      lockfile = root.join('Gemfile.lock')
      definition = Bundler::Definition.build(gemfile, lockfile, nil)

      groups = definition.groups - LicenseFinder.config.ignore_groups

      new(definition.specs_for(groups).map { |spec| GemSpecDetails.new(spec).dependency })
    end

    def initialize(dependencies)
      @dependencies = dependencies
    end

    def self.from_yaml(yml)
      deps = YAML.load(yml)
      new(deps.map { |dhash| Dependency.from_hash(dhash) })
    end

    def merge(new_list)
      deps = new_list.dependencies.map do |new_dep|
        old_dep = dependencies.detect { |d| d.name == new_dep.name }

        if old_dep
          old_dep.merge(new_dep)
        else
          new_dep
        end
      end

      deps += dependencies.select { |d| d.source != "bundle" }

      self.class.new(deps)
    end

    def as_yaml
      dependencies.sort_by(&:name).map(&:as_yaml)
    end

    def to_yaml
      as_yaml.to_yaml
    end

    def to_s
      dependencies.sort_by(&:name).map(&:to_s).join("\n")
    end

    def action_items
      dependencies.sort_by(&:name).reject(&:approved).map(&:to_s).join("\n")
    end
  end
end

