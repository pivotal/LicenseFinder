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
      @dependency = dependency
      @package = package
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
        # Only save *changed* dependencies. This ensures re-running
        # `license_finder` won't always update the DB, and therefore won't always
        # update the HTML/markdown reports with a new timestamp.
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
