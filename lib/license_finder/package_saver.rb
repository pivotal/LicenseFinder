require 'forwardable'

module LicenseFinder
  class PackageSaver
    extend Forwardable
    def_delegators :package, :license, :children, :groups, :summary, :description, :spec
    def_delegators :spec, :name, :version, :homepage

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
        dependency.version = version.to_s
        dependency.summary = summary
        dependency.description = description
        dependency.homepage = homepage
        dependency.bundler_group_names = groups.map(&:to_s)
        dependency.children_names = children
        dependency.apply_better_license license
        dependency.save
      end
      dependency
    end
  end
end
