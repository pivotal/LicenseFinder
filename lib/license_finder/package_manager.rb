module LicenseFinder
  # Super-class for the different package managers
  # (Bundler, NPM, Pip, etc.)
  #
  # For guidance on adding a new package manager use the shared behavior
  #
  #     it_behaves_like "a PackageManager"
  #
  # Additional guidelines are:
  #
  # - implement #current_packages, to return a list of `Package`s this package manager is tracking
  # - implement #package_path, a `Pathname` which, if the file exists, indicates the package manager is in use on this project
  #
  class PackageManager
    def self.package_managers
      [Bundler, NPM, Pip, Bower, Maven, Gradle, CocoaPods, Rebar]
    end

    def self.current_packages(options)
      package_managers
        .map { |pm| pm.new(options) }
        .select(&:active?)
        .flat_map(&:current_packages_with_relations)
    end

    def initialize options={}
      @logger       = options[:logger] || Core.default_logger
      @project_path = options[:project_path]
    end

    def active?
      package_path.exist?
        .tap { |is_active| logger.active self.class, is_active }
    end

    def current_packages_with_relations
      packages = current_packages
      packages.each do |parent|
        parent.children.each do |child_name|
          child = packages.detect { |child| child.name == child_name }
          child.parents << parent.name if child
        end
      end
      packages
    end

    private

    attr_reader :logger, :project_path
  end
end

require 'license_finder/package_managers/bower'
require 'license_finder/package_managers/bundler'
require 'license_finder/package_managers/npm'
require 'license_finder/package_managers/pip'
require 'license_finder/package_managers/maven'
require 'license_finder/package_managers/cocoa_pods'
require 'license_finder/package_managers/gradle'
require 'license_finder/package_managers/rebar'

require 'license_finder/package'
