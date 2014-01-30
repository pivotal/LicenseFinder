require 'forwardable'

module LicenseFinder
  class PackageSaver
    extend Forwardable
    def_delegators :package, :license, :children, :groups, :summary, :description, :version, :homepage

    attr_reader :dependency, :package

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
        dependency.save_changes
      end
      dependency
    end

    private

    def self.find_or_create_by_name(package)
      dependency = Dependency.named(package.name)
      new(dependency, package)
    end
  end
end
