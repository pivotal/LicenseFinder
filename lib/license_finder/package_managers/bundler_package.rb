module LicenseFinder
  class BundlerPackage < Package
    attr_reader :gem_def

    def initialize(gem_def, bundler_def, options={})
      super(
        gem_def.name,
        gem_def.version.to_s,
        options.merge(
          summary: gem_def.summary,
          description: gem_def.description,
          homepage: gem_def.homepage,
          children: gem_def.dependencies.map(&:name),
          groups: Array(bundler_def && bundler_def.groups)
        )
      )
      @gem_def = gem_def
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
