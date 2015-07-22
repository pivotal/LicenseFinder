module LicenseFinder
  class PackageDelta
    STATUSES = [:added, :removed, :unchanged]

    def initialize(status, current_package, previous_package)
      @status = status
      @current_package = current_package
      @previous_package = previous_package
    end

    def name
      pick_package.name
    end

    def current_version
      @current_package ? @current_package.version : nil
    end

    def previous_version
      @previous_package ? @previous_package.version : nil
    end

    def subproject_paths
      pick_package.subproject_paths
    end

    def status
      @status
    end

    def licenses
      pick_package.licenses
    end

    def merged_package?
      pick_package.class == MergedPackage
    end

    def method_missing(method_name)
      nil
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

    def <=>(other)
      STATUSES.index(status) <=> STATUSES.index(other.status)
    end

    private

    def pick_package
      @current_package ? @current_package : @previous_package
    end
  end
end
