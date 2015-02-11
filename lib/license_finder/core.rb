require 'license_finder/logger'

require 'license_finder/license'

require 'license_finder/configuration'
require 'license_finder/package_manager'
require 'license_finder/decisions'
require 'license_finder/decision_applier'

require 'forwardable'
module LicenseFinder
  # Coordinates setup
  class Core
    def self.default_logger
      Logger::Default.new
    end

    # +options+ look like:
    # {
    #   logger: { quiet: true, debug: false },
    #   project_path: "./some/project/path/"
    #   gradle_command: "gradlew",
    #   decisions_file: "./some/path.yml",
    # }
    # +gradle_command+ and +decisions_file+ are optional, see Configuration
    def initialize(options)
      @logger = Logger.new(options.fetch(:logger))
      @project_path = Pathname(options.fetch(:project_path))
      @config = Configuration.with_optional_saved_config(options, project_path)
      @decisions = Decisions.saved!(config.decisions_file)
    end

    def modifying
      yield
      decisions.save!(config.decisions_file)
    end

    extend Forwardable
    def_delegators :decision_applier, :acknowledged, :unapproved
    attr_reader :decisions

    def project_name
      decisions.project_name || project_path.basename.to_s
    end

    private

    attr_reader :config, :logger, :project_path

    # The core of the system. The saved decisions are applied to the current
    # packages.
    def decision_applier
      # lazy, do not move to `initialize`
      DecisionApplier.new(decisions: decisions, packages: current_packages)
    end

    def current_packages
      # lazy, do not move to `initialize`
      PackageManager.current_packages(
        logger: logger,
        project_path: project_path,
        gradle_command: config.gradle_command,
        rebar_command: config.rebar_command,
        rebar_deps_dir: config.rebar_deps_dir,
        ignore_groups: decisions.ignored_groups,
      )
    end
  end
end

