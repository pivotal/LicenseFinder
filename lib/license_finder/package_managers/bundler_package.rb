module LicenseFinder
  class BundlerPackage < Package
    extend Forwardable
    def_delegators :gem_def, :summary, :description, :name, :homepage

    attr_reader :gem_def

    def initialize(gem_def, bundler_def)
      @gem_def = gem_def
      @bundler_def = bundler_def
    end

    def groups
      Array(@bundler_def && @bundler_def.groups)
    end

    def version
      gem_def.version.to_s
    end

    def children
      gem_def.dependencies.map(&:name)
    end

    private

    def install_path
      gem_def.full_gem_path
    end

    def license_names_from_spec
      gem_def.licenses
    end
  end
end
