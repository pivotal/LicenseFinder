# frozen_string_literal: true

module LicenseFinder
  class Scanner
    PACKAGE_MANAGERS = [
      GoModules, GoDep, GoWorkspace, Go15VendorExperiment, Glide, Gvt, Govendor, Trash, Dep, Bundler, NPM, Pip,
      Yarn, Bower, Maven, Gradle, CocoaPods, Rebar, Erlangmk, Nuget, Carthage, Mix, Conan, Sbt, Cargo, Dotnet, Composer, Pipenv,
      Conda, Spm
    ].freeze

    class << self
      def remove_subprojects(paths)
        paths.reject { |path| subproject?(Pathname(path)) }
      end

      def supported_package_manager_ids
        PACKAGE_MANAGERS.map(&:id)
      end

      private

      def subproject?(path)
        subproject = true
        PACKAGE_MANAGERS.each do |package_manager_class|
          package_manager = package_manager_class.new(project_path: path)
          subproject &&= !package_manager.project_root?
        end
        subproject
      end
    end

    def initialize(config = { project_path: Pathname.new('') })
      @config = config
      @project_path = @config[:project_path]
      @logger = @config[:logger]
      @enabled_package_manager_ids = @config[:enabled_package_manager_ids]
    end

    def active_packages
      package_managers = active_package_managers
      installed_package_managers = package_managers.select { |pm| pm.installed?(@logger) }
      installed_package_managers.flat_map(&:current_packages_with_relations)
    end

    def active_package_managers
      return @package_managers if @package_managers

      active_pm_classes = []
      enabled_package_managers.each do |pm_class|
        active = pm_class.new(@config).active?

        if active
          @logger.info pm_class, 'is active', color: :green
          active_pm_classes << pm_class
        else
          @logger.debug pm_class, 'is not active', color: :red
        end
      end

      @logger.info 'License Finder', 'No active and installed package managers found for project.', color: :red if active_pm_classes.empty?

      active_pm_classes -= active_pm_classes.map(&:takes_priority_over)
      @package_managers = active_pm_classes.map { |pm_class| pm_class.new(@config) }
    end

    private

    def enabled_package_managers
      enabled_pm_ids = @enabled_package_manager_ids

      return PACKAGE_MANAGERS unless enabled_pm_ids

      enabled_pm_classes = PACKAGE_MANAGERS.select { |pm_class| enabled_pm_ids.include?(pm_class.id) }

      if enabled_pm_classes.length != enabled_pm_ids.length
        unsupported_pm_ids = enabled_pm_ids - self.class.supported_package_manager_ids
        raise "Unsupported package manager: #{unsupported_pm_ids.join(', ')}"
      end

      enabled_pm_classes
    end
  end
end
