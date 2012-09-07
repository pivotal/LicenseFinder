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
        old_dep = self.dependencies.detect { |d| d.name == new_dep.name }
        if old_dep && old_dep.license == new_dep.license
          Dependency.new(
            'name' => new_dep.name,
            'version' => new_dep.version,
            'license' => new_dep.license,
            'approved' => (old_dep.approved || new_dep.approved),
            'license_url' => old_dep.license_url,
            'notes' => old_dep.notes,
            'license_files' => new_dep.license_files,
            'readme_files' => new_dep.readme_files
          )
        elsif old_dep && new_dep.license == 'other'
          Dependency.new(
            'name' => new_dep.name,
            'version' => new_dep.version,
            'license' => old_dep.license,
            'approved' => old_dep.approved,
            'license_url' => old_dep.license_url,
            'notes' => old_dep.notes,
            'license_files' => new_dep.license_files,
            'readme_files' => new_dep.readme_files
          )
        else
          new_dep
        end
      end

      self.class.new(deps)
    end

    def to_yaml
      result = "--- \n"
      dependencies.sort_by(&:name).inject(result) { |r, d| r << d.to_yaml_entry; r }
    end

    def to_s
      dependencies.sort_by(&:name).map(&:to_s).join("\n")
    end

    def action_items
      dependencies.sort_by(&:name).reject(&:approved).map(&:to_s).join("\n")
    end
  end
end

