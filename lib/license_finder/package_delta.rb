module LicenseFinder
  class PackageDelta
    def initialize(status, current_package, previous_package)
      @status = status
      @current_package = current_package
      @previous_package = previous_package
    end

    def name
      @previous_package ? @previous_package.name : @current_package.name
    end

    def current_version
      @current_package ? @current_package.version : nil
    end

    def previous_version
      @previous_package ? @previous_package.version : nil
    end

    def status
      @status.to_s
    end

    def self.added(package)
      new(:added, package, nil)
    end

    def self.removed(package)
      new(:removed, nil, package)
    end

    def self.unchanged(current_package, previous_package)
      new(:unchanged, current_package, previous_package)
    end

    def method_missing(method_name)
      nil
    end

    def licenses
      @current_package ? @current_package.licenses : @previous_package.licenses
    end
  end
end