# encoding: utf-8

module LicenseFinder
  class DependencyList
    include Viewable

    attr_reader :dependencies

    def self.from_bundler
      dep_list = new(Bundle.new.gems.map(&:to_dependency))
      setup_parents_of_dependencies(dep_list)
      dep_list
    end

    def self.setup_parents_of_dependencies(dep_list)
      dependency_index = {}
      dep_list.dependencies.each do |dep|
        dependency_index[dep.name] = dep
      end

      dep_list.dependencies.each do |dep|
        dep.children.each do |child_dep|
          license_finder_dependency = dependency_index[child_dep]
          license_finder_dependency.parents << dep.name if license_finder_dependency
        end
      end
    end

    def self.from_yaml(yaml)
      deps = YAML.load(yaml)
      new(deps.map { |attrs| Dependency.new(attrs) })
    end

    def initialize(dependencies)
      @dependencies = dependencies
    end

    def save!
      dependencies.map(&:save!)
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
      sorted_dependencies.map(&:as_yaml)
    end

    def to_s
      sorted_dependencies.map(&:to_s).join("\n")
    end

    def action_items
      sorted_dependencies.reject(&:approved).map(&:to_s).join "\n"
    end

    private

    def unapproved_dependencies
      dependencies.reject(&:approved)
    end

    def sorted_dependencies
      dependencies.sort_by(&:name)
    end

    def grouped_dependencies
      dependencies.group_by(&:license).sort_by { |_, group| group.size }.reverse
    end
  end
end
