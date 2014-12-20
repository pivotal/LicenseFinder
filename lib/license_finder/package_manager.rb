module LicenseFinder
  class PackageManager
    def self.package_managers
      [Bundler, NPM, Pip, Bower, Maven, Gradle, CocoaPods]
    end

    def self.current_packages(logger)
      package_managers.
        map { |pm| pm.new(logger: logger) }.
        select(&:active?).
        map(&:current_packages_with_relations).
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

    def current_packages_with_relations
      packages = current_packages
      packages.each do |parent|
        parent.children.each do |child_name|
          child = packages.detect { |child| child.name == child_name }
          child.parents << parent.name if child
        end
      end
      packages
    end

    private

    def injected_package_path
      @package_path || package_path
    end
  end
end
