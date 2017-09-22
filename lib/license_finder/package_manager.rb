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
      [GoDep, GoWorkspace, GoVendor, Gvt, Bundler, NPM, Pip, Bower, Maven, Gradle, CocoaPods, Rebar, Nuget, Carthage, Mix]
    end

    def self.current_packages(options)
      active_package_managers = package_managers
        .map { |pm| pm.new(options) }
        .select(&:active?)
      active_package_managers.flat_map(&:current_packages_with_relations)
    end

    def self.installed?(logger=Core.default_logger)
      if package_management_command.nil?
        logger.installed self, "no command defined" # TODO comment me out
        return true
      end

      if command_exists?(package_management_command)
        logger.installed self, true
        return true
      end

      logger.installed self, false
      return false
    end

    def self.package_management_command
      nil
    end

    def initialize options={}
      @logger       = options[:logger] || Core.default_logger
      @project_path = options[:project_path]
    end

    def active?
      self.class.installed?(logger) &&
        package_path.exist?.tap { |is_active| logger.active self.class, is_active }
    end

    def capture(command)
      [`#{command}`, $?.success?]
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

    def self.command_exists? command
      if LicenseFinder::Platform.windows?
        `where #{command} 2>NUL`
      else
        `which #{command} 2>/dev/null`
      end
      status = $?
      return status.success?
    end

    private

    attr_reader :logger, :project_path
  end
end

require 'license_finder/package_managers/bower'
require 'license_finder/package_managers/go_workspace'
require 'license_finder/package_managers/go_vendor'
require 'license_finder/package_managers/go_dep'
require 'license_finder/package_managers/gvt'
require 'license_finder/package_managers/bundler'
require 'license_finder/package_managers/npm'
require 'license_finder/package_managers/pip'
require 'license_finder/package_managers/maven'
require 'license_finder/package_managers/mix'
require 'license_finder/package_managers/cocoa_pods'
require 'license_finder/package_managers/carthage'
require 'license_finder/package_managers/gradle'
require 'license_finder/package_managers/rebar'
require 'license_finder/package_managers/nuget'

require 'license_finder/package'
