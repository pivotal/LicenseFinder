module LicenseFinder
  class Scanner
    PACKAGE_MANAGERS = [GoDep, GoWorkspace, Go15VendorExperiment, Glide, Gvt, Govendor, Dep, Bundler, NPM, Pip,
                        Yarn, Bower, Maven, Gradle, CocoaPods, Rebar, Nuget, Carthage, Mix, Conan, Sbt].freeze

    def initialize(config = { project_path: Pathname.new('') })
      @config = config
      @project_path = @config[:project_path]
      @logger = @config[:logger]
    end

    def active_packages
      package_managers = active_package_managers
      installed_package_managers = package_managers.select { |pm| pm.class.installed?(@logger) }
      installed_package_managers.flat_map(&:current_packages_with_relations)
    end

    def active_package_managers
      return @package_managers if @package_managers

      active_pm_classes = []
      PACKAGE_MANAGERS.each do |pm_class|
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
  end
end
