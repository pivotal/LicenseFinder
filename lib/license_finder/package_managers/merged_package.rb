module LicenseFinder
  class MergedPackage < Package
    attr_reader :dependency

    def initialize(package, aggregate_paths)
      @dependency = package
      @aggregate_paths = aggregate_paths.map { |p| Pathname(p) }
      super(package.name, package.version)
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

    def approved_manually?
      dependency.approved_manually?
    end

    def approved?
      dependency.approved?
    end

    def whitelisted?
      dependency.whitelisted?
    end

    def blacklisted?
      dependency.blacklisted?
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
      if other.instance_of? MergedPackage
        other.dependency.eql?(dependency)
      else
        dependency.eql?(other)
      end
  end

    def ==(other)
      dependency.eql?(other.dependency) && aggregate_paths.eql?(other.aggregate_paths)
    end

    def hash
      dependency.hash
    end

    def method_missing(_method_name)
      nil
    end
  end
end
