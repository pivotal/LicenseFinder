module LicenseFinder
  class MergedPackage

    attr_reader :dependency

    def initialize(dependency, subproject_paths)
      @dependency = dependency
      @subproject_paths = subproject_paths.map { |p| Pathname(p) }
    end

    def name
      dependency.name
    end

    def version
      dependency.version
    end

    def licenses
      dependency.licenses
    end

    def install_path
      dependency.install_path
    end

    def subproject_paths
      @subproject_paths.map { |p| p.expand_path.to_s }
    end

    def <=>(other)
      dependency <=> other.dependency
    end

    def eql?(other)
      dependency.eql?(other.dependency)
    end

    def hash
      dependency.hash
    end

    def method_missing(method_name)
      nil
    end
  end
end
