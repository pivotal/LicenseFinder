module LicenseFinder
  class PackageManager
    def self.package_managers
      [Bundler, NPM, Pip, Bower, Maven, Gradle, CocoaPods]
    end

    def self.current_packages(logger)
      package_managers.
        map { |pm| pm.new(logger: logger) }.
        select(&:active?).
        map(&:current_packages).
        flatten
    end

    attr_reader :logger

    def initialize options={}
      @logger       = options[:logger] || LicenseFinder::Logger::Default.new
      @package_path = options[:package_path] # dependency injection for tests
    end

    def active?
      injected_package_path.exist?.tap { |is_active| logger.active self.class, is_active }
    end

    private

    def injected_package_path
      @package_path || package_path
    end
  end
end
