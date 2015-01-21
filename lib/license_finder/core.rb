require 'forwardable'
module LicenseFinder
  class Core
    extend Forwardable

    def initialize(options)
      @logger = Logger.new(options.fetch(:logger))
      @config = Configuration.with_optional_saved_config(options)
      @decisions = Decisions.saved!(config.decisions_file)
    end

    def modifying
      yield
      decisions.save!(config.decisions_file)
    end

    attr_reader :decisions
    def_delegators :decision_applier, :acknowledged, :unapproved

    def project_name
      decisions.project_name || Pathname.pwd.basename.to_s
    end

    private

    attr_reader :config, :logger

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
        gradle_command: config.gradle_command,
        ignore_groups: decisions.ignored_groups
      )
    end
  end
end

