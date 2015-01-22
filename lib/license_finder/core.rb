require 'forwardable'
module LicenseFinder
  # Coordinates setup
  # +options+ look like:
  # {
  #   logger: { quiet: true, debug: false },
  #   gradle_command: "gradlew",
  #   decisions_file: "./some/path.yml",
  #   project_path: "./some/project/path/"
  # }
  class Core
    extend Forwardable

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

    attr_reader :decisions
    def_delegators :decision_applier, :acknowledged, :unapproved

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
        ignore_groups: decisions.ignored_groups
      )
    end
  end
end

