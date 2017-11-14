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
    include LicenseFinder::SharedHelpers

    class << self
      def package_managers
        [GoDep, GoWorkspace, Go15VendorExperiment, Glide, Gvt, Govendor, Dep, Bundler, NPM, Pip,
         Yarn, Bower, Maven, Gradle, CocoaPods, Rebar, Nuget, Carthage, Mix, Conan]
      end

      def active_packages(options = { project_path: Pathname.new('') })
        package_managers = active_package_managers(options)
        installed_package_managers = package_managers.select { |pm| pm.class.installed?(options[:logger]) }
        installed_package_managers.flat_map(&:current_packages_with_relations)
      end

      def active_package_managers(options = { project_path: Pathname.new('') })
        logger = options[:logger]

        active_pm_classes = []
        package_managers.each do |pm_class|
          active = pm_class.new(options).active?
          if active
            logger.info pm_class, 'is active', color: :green
            active_pm_classes << pm_class
          else
            logger.debug pm_class, 'is not active', color: :red
          end
        end

        if active_pm_classes.empty?
          logger.info 'License Finder', 'No active and installed package managers found for project.', color: :red
        end

        active_pm_classes -= active_pm_classes.map(&:takes_priority_over)
        active_pm_classes.map { |pm_class| pm_class.new(options) }
      end

      def takes_priority_over
        nil
      end

      def installed?(logger = Core.default_logger)
        if package_management_command.nil?
          logger.debug self, 'no command defined' # TODO: comment me out
          true
        elsif command_exists?(package_management_command)
          logger.debug self, 'is installed', color: :green
          true
        else
          logger.info self, 'is not installed', color: :red
          false
        end
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

    def initialize(options = {})
      @logger       = options[:logger] || Core.default_logger
      @project_path = options[:project_path]
    end

    def active?
      path = detected_package_path
      path && path.exist?
    end

    def detected_package_path
      possible_package_paths.find(&:exist?)
    end

    def prepare
      if self.class.prepare_command
        _stdout, _stderr, status = Cmd.run(self.class.prepare_command)
        raise "Prepare command '#{self.class.prepare_command}' failed" unless status.success?
      else
        logger.debug self.class, 'no prepare step provided', color: :red
      end
    end

    def current_packages_with_relations
      packages = current_packages
      packages.each do |parent|
        parent.children.each do |child_name|
          child = packages.detect { |child_package| child_package.name == child_name }
          child.parents << parent.name if child
        end
      end
      packages
    end

    def self.command_exists?(command)
      _stdout, _stderr, status =
        if LicenseFinder::Platform.windows?
          Cmd.run("where #{command}")
        else
          Cmd.run("which #{command}")
        end

      status.success?
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
