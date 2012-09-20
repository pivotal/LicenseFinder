# encoding: utf-8

module LicenseFinder
  class DependencyList
    attr_reader :dependencies

    def self.from_bundler(bundle)
      dep_list = new(bundle.gems.map(&:to_dependency))
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

    def initialize(dependencies)
      @dependencies = dependencies
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
  end
end
