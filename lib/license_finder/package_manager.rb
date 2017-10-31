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
  # - implement #possible_package_paths, an array of `Pathname`s which are the possible locations which contain a configuration file/folder indicating the package manager is in use.
  # - implement(Optional) #package_management_command, string for invoking the package manager
  # - implement(Optional) #prepare_command, string for fetching dependencies for package manager (runs when the --prepare flag is passed to license_finder)

  class PackageManager
    class << self
      def package_managers
        [GoDep, GoWorkspace, Go15VendorExperiment, Glide, Gvt, Govendor, Dep, Bundler, NPM, Pip,
         Yarn, Bower, Maven, Gradle, CocoaPods, Rebar, Nuget, Carthage, Mix, Conan]
      end

      def active_packages(options)
        active_package_managers(options).flat_map(&:current_packages_with_relations)
      end

      def active_package_managers(options={:project_path => Pathname.new('')})
        active_pm_classes = package_managers.select { |pm_class| pm_class.new(options).active? }
        active_pm_classes -= active_pm_classes.map(&:takes_priority_over)
        active_pm_classes.map { |pm_class| pm_class.new(options) }
      end

      def takes_priority_over
        nil
      end

      def installed?(logger=Core.default_logger)
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

      # see class description
      def package_management_command
        nil
      end

      # see class description
      def prepare_command
        nil
      end
    end

    def initialize options={}
      @logger       = options[:logger] || Core.default_logger
      @project_path = options[:project_path]
    end

    def active?
      path = detected_package_path
      self.class.installed?(logger) &&
          !path.nil? &&
        path.exist?.tap { |is_active| logger.active self.class, is_active }
    end

    def detected_package_path
      possible_package_paths.find { |path|
        path.exist?
      }
    end

    def prepare
      if self.class.prepare_command
        _, success = capture(self.class.prepare_command)
        raise "Prepare command '#{self.class.prepare_command}' failed" unless success
      end

      logger.prepare self.class, self.class.prepare_command
    end

    def capture(command)
      require 'open3'
      stdout, stderr, process = Open3.capture3(command)
      [stdout, stderr, process.exitstatus]
    end

    def current_packages_with_relations
      packages = self.current_packages
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
require 'license_finder/package_managers/go_15vendorexperiment'
require 'license_finder/package_managers/go_dep'
require 'license_finder/package_managers/gvt'
require 'license_finder/package_managers/glide'
require 'license_finder/package_managers/govendor'
require 'license_finder/package_managers/bundler'
require 'license_finder/package_managers/npm'
require 'license_finder/package_managers/yarn'
require 'license_finder/package_managers/pip'
require 'license_finder/package_managers/maven'
require 'license_finder/package_managers/mix'
require 'license_finder/package_managers/cocoa_pods'
require 'license_finder/package_managers/carthage'
require 'license_finder/package_managers/gradle'
require 'license_finder/package_managers/rebar'
require 'license_finder/package_managers/nuget'
require 'license_finder/package_managers/dep'
require 'license_finder/package_managers/conan'

require 'license_finder/package'
