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
    attr_reader :config

    def self.default_logger
      Logger::Default.new
    end

    # Default +options+:
    # {
    #   project_path: Pathname.pwd
    #   logger: {},   # can include quiet: true or debug: true
    #   decisions_file: "doc/dependency_decisions.yml",
    #   gradle_command: "gradle",
    #   rebar_command: "rebar",
    #   rebar_deps_dir: "deps",
    # }
    def initialize(options = {})
      @logger = Logger.new(options.fetch(:logger, {}))
      @config = Configuration.with_optional_saved_config(options)
    end

    def modifying
      yield
      decisions.save!(config.decisions_file_path)
    end

    extend Forwardable
    def_delegators :decision_applier, :acknowledged, :unapproved, :blacklisted

    def project_name
      decisions.project_name || config.project_path.basename.to_s
    end

    def decisions
      @decisions ||= Decisions.fetch_saved(config.decisions_file_path)
    end

    private

    attr_reader :logger

    # The core of the system. The saved decisions are applied to the current
    # packages.
    def decision_applier
      # lazy, do not move to `initialize`
      @applier ||= DecisionApplier.new(decisions: decisions, packages: current_packages)
    end

    def current_packages
      # lazy, do not move to `initialize`
      PackageManager.current_packages(
        logger: logger,
        project_path: config.project_path,
        ignore_groups: decisions.ignored_groups,
        go_full_version: config.go_full_version,
        gradle_command: config.gradle_command,
        gradle_include_groups: config.gradle_include_groups,
        rebar_command: config.rebar_command,
        rebar_deps_dir: config.rebar_deps_dir,
      )
    end
  end
end

