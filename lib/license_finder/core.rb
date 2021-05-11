# frozen_string_literal: true

require 'forwardable'

require 'license_finder/logger'
require 'license_finder/license'

require 'license_finder/configuration'
require 'license_finder/package_manager'
require 'license_finder/decisions'
require 'license_finder/decisions_factory'
require 'license_finder/decision_applier'
require 'license_finder/scanner'

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
    #   logger: nil,   # can be :quiet or :debug
    #   decisions_file: "doc/dependency_decisions.yml",
    #   gradle_command: "gradle",
    #   rebar_command: "rebar",
    #   rebar_deps_dir: "deps",
    # }
    def initialize(configuration)
      @logger = Logger.new(configuration.logger_mode)
      @config = configuration
      @scanner = Scanner.new(options)
    end

    def modifying
      yield
      decisions.save!(config.decisions_file_path)
    end

    extend Forwardable
    def_delegators :decision_applier, :acknowledged, :unapproved, :restricted, :any_packages?

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
      clear_logs
      package_managers = @scanner.active_package_managers
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
      @decision_applier ||= DecisionApplier.new(decisions: decisions, packages: current_packages)
    end

    def current_packages
      # lazy, do not move to `initialize`
      @scanner.active_packages
    end

    def clear_logs
      FileUtils.rmtree config.log_directory, secure: true if File.directory? config.log_directory
    end

    def options # rubocop:disable Metrics/AbcSize
      {
        logger: logger,
        project_path: config.project_path,
        log_directory: File.join(config.log_directory, project_name),
        ignored_groups: decisions.ignored_groups,
        enabled_package_manager_ids: config.enabled_package_manager_ids,
        go_full_version: config.go_full_version,
        gradle_command: config.gradle_command,
        gradle_include_groups: config.gradle_include_groups,
        maven_include_groups: config.maven_include_groups,
        maven_options: config.maven_options,
        npm_options: config.npm_options,
        pip_requirements_path: config.pip_requirements_path,
        python_version: config.python_version,
        rebar_command: config.rebar_command,
        rebar_deps_dir: config.rebar_deps_dir,
        elixir_command: config.elixir_command,
        mix_command: config.mix_command,
        mix_deps_dir: config.mix_deps_dir,
        prepare: config.prepare,
        prepare_no_fail: config.prepare_no_fail,
        sbt_include_groups: config.sbt_include_groups,
        conda_bash_setup_script: config.conda_bash_setup_script,
        composer_check_require_only: config.composer_check_require_only
      }
    end
  end
end
