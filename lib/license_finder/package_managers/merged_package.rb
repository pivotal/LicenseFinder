module LicenseFinder
  class MergedPackage
    def initialize(dependency, subproject_path)
      @dependency = dependency
      @subproject_path = subproject_path
    end

    def name
      @dependency.name
    end

    def version
      @dependency.version
    end

    def licenses
      @dependency.licenses
    end

    def subproject_path
      @subproject_path
    end

    def <=>(other)
      name <=> other.name
    end

    def method_missing(method_name)
      nil
    end
  end
end