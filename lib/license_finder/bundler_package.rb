module LicenseFinder
  class BundlerPackage < Package
    extend Forwardable
    def_delegators :gem_def, :summary, :description, :name, :homepage

    attr_reader :gem_def
    attr_accessor :children

    def initialize(gem_def, bundler_def)
      @gem_def = gem_def
      @bundler_def = bundler_def
      @children = []
    end

    def groups
      Array(@bundler_def && @bundler_def.groups)
    end

    def version
      gem_def.version.to_s
    end

    private

    def install_path
      gem_def.full_gem_path
    end

    def license_from_spec
      gem_def.license
    end
  end
end
