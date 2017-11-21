module LicenseFinder
  class MergedPackage < Package
    extend Forwardable
    attr_reader :dependency

    def initialize(package, aggregate_paths)
      @dependency = package
      @aggregate_paths = aggregate_paths.map { |p| Pathname(p) }
      super(package.name, package.version)
    end

    def_delegators :@dependency, :name, :version, :authors, :summary, :description, :homepage, :children, :parents,
                   :groups, :whitelisted, :blacklisted, :manual_approval, :install_path, :licenses, :approved_manually?,
                   :approved_manually!, :approved?, :whitelisted!, :whitelisted?, :blacklisted!, :blacklisted?, :hash,
                   :activations, :missing, :license_names_from_spec, :decided_licenses, :licensing, :decide_on_license,
                   :license_files, :package_manager, :missing?, :log_activation

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

    def method_missing(_method_name)
      nil
    end
  end
end
