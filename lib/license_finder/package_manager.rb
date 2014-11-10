module LicenseFinder
  class PackageManager
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
