require 'forwardable'

module LicenseFinder
  class PackageSaver
    extend Forwardable
    def_delegators :package, :licenses, :children, :groups, :summary, :description, :version, :homepage, :missing

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
      dependency.version = version.to_s
      dependency.summary = summary
      dependency.description = description
      dependency.homepage = homepage
      dependency.bundler_group_names = groups.map(&:to_s)
      dependency.children_names = children
      dependency.set_licenses licenses
      dependency.missing = missing

      # Only save *changed* dependencies. This ensures re-running
      # `license_finder` won't always update the DB, and therefore won't always
      # update the HTML/markdown reports with a new timestamp.
      dependency.save_changes
      dependency
    end

    private

    def self.find_or_create_by_name(package)
      dependency = Dependency.named(package.name)
      new(dependency, package)
    end
  end
end
