module LicenseFinder
  class MergedPackage
    attr_reader :dependency

    def initialize(dependency, aggregate_paths)
      @dependency = dependency
      @aggregate_paths = aggregate_paths.map { |p| Pathname(p) }
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

    def authors
      dependency.authors
    end

    def homepage
      dependency.homepage
    end

    def summary
      dependency.summary
    end

    def description
      dependency.description
    end

    def groups
      dependency.groups
    end

    def package_manager
      dependency.package_manager
    end

    def aggregate_paths
      @aggregate_paths.map { |p| p.expand_path.to_s }
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

    def method_missing(_method_name)
      nil
    end
  end
end
