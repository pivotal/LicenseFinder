require 'forwardable'

require 'license_finder/logger'
require 'license_finder/license'

require 'license_finder/configuration'
require 'license_finder/package_manager'
require 'license_finder/decisions'
require 'license_finder/decisions_factory'
require 'license_finder/decision_applier'

module LicenseFinder
  # Coordinates setup
  class Core
    attr_reader :config

    def self.default_logger
      Logger.new
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
    def initialize(configuration)
      @logger = Logger.new(configuration.logger_mode)
      @config = configuration
    end

    def modifying
      yield
      decisions.save!(config.decisions_file_path)
    end

    extend Forwardable
    def_delegators :decision_applier, :acknowledged, :unapproved, :blacklisted, :any_packages?

    def project_name
      decisions.project_name || config.project_path.basename.to_s
    end

    def project_path
      config.project_path
    end

    def decisions
      @decisions ||= DecisionsFactory.decisions(config.decisions_file_path)
    end

    def prepare_projects
      package_managers = PackageManager.active_package_managers options
      package_managers.each do |manager|
        logger.debug manager.class, 'Running prepare on project'
        manager.prepare
        logger.debug manager.class, 'Finished prepare on project', color: :green
      end
    end

    private

    attr_reader :logger

    # The core of the system. The saved decisions are applied to the current
    # packages.
    def decision_applier
      # lazy, do not move to `initialize`
      # Needs to be lazy loaded to prvent multiple decision appliers being created each time
      @applier ||= DecisionApplier.new(decisions: decisions, packages: current_packages)
    end

    def current_packages
      # lazy, do not move to `initialize`
      PackageManager.active_packages options
    end

    def options
      {
        logger: logger,
        project_path: config.project_path,
        ignored_groups: decisions.ignored_groups,
        go_full_version: config.go_full_version,
        gradle_command: config.gradle_command,
        gradle_include_groups: config.gradle_include_groups,
        maven_include_groups: config.maven_include_groups,
        maven_options: config.maven_options,
        pip_requirements_path: config.pip_requirements_path,
        rebar_command: config.rebar_command,
        rebar_deps_dir: config.rebar_deps_dir,
        mix_command: config.mix_command,
        mix_deps_dir: config.mix_deps_dir,
        prepare: config.prepare
      }
    end
  end
end
