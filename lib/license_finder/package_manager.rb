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

    def self.command_exists?(command)
      _stdout, _stderr, status =
        if LicenseFinder::Platform.windows?
          Cmd.run("where #{command}")
        else
          Cmd.run("which #{command}")
        end

      status.success?
    end

    def initialize(options = {})
      @prepare_no_fail = options[:prepare_no_fail]
      @logger       = options[:logger] || Core.default_logger
      @project_path = options[:project_path]
      @log_directory = options[:log_directory]
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
        _stdout, stderr, status =  Dir.chdir(project_path) { Cmd.run(self.class.prepare_command) }
        unless status.success?
          log_errors stderr
          raise "Prepare command '#{self.class.prepare_command}' failed" unless @prepare_no_fail
        end
      else
        logger.debug self.class, 'no prepare step provided', color: :red
      end
    end

    def current_packages_with_relations
      begin
        packages = current_packages
      rescue StandardError => e
        raise e unless @prepare_no_fail
        packages = []
      end

      packages.each do |parent|
        parent.children.each do |child_name|
          child = packages.detect { |child_package| child_package.name == child_name }
          child.parents << parent.name if child
        end
      end
      packages
    end

    private

    attr_reader :logger, :project_path

    def log_errors(stderr)
      logger.info self.class.prepare_command, 'did not succeed.', color: :red
      logger.info self.class.prepare_command, stderr, color: :red
      log_to_file stderr
    end

    def log_to_file(contents)
      FileUtils.mkdir_p @log_directory
      log_file = File.join(@log_directory, "prepare_#{self.class.package_management_command || 'errors'}.log")
      File.open(log_file, 'w') do |f|
        f.write("Prepare command \"#{self.class.prepare_command}\" failed with:\n")
        f.write("#{contents}\n\n")
      end
    end
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
