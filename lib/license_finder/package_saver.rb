require 'forwardable'

module LicenseFinder
  class PackageSaver
    extend Forwardable
    def_delegators :spec, :name, :version, :homepage
    def_delegators :package, :bundler_dependency, :license, :children, :groups, :summary, :description

    attr_reader :dependency, :package

    def self.find_or_create_by_name(package)
      dependency = Dependency.named(package.spec.name)
      new(dependency, package)
    end

    def self.save_all(packages)
      packages.map do |package|
        find_or_create_by_name(package).save
      end
    end

    def initialize(dependency, package)
      @package = package
      @dependency = dependency
    end

    def save
      DB.transaction do
        apply_dependency_definition
        sync_bundler_groups
        sync_children
        apply_better_license
        dependency.save_changes
      end
      dependency
    end

    private

    def spec
      package.spec
    end

    def apply_dependency_definition
      dependency.version = version.to_s
      dependency.summary = summary
      dependency.description = description
      dependency.homepage = homepage
    end

    def sync_bundler_groups
      dependency.bundler_group_names = groups.map(&:to_s)
    end

    def sync_children
      dependency.children_names = children
    end

    def apply_better_license
      dependency.apply_better_license license
    end
  end
end
