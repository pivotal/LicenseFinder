module LicenseFinder
  class PackageManager
    def initialize options={}
      @package_path = options[:package_path] # dependency injection for tests
    end

    def active?
      injected_package_path.exist?
    end

    private

    def injected_package_path
      @package_path || package_path
    end
  end
end
