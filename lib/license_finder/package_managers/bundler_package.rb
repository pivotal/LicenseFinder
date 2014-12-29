module LicenseFinder
  class BundlerPackage < Package
    attr_reader :gem_def

    def initialize(spec, bundler_def, options={})
      super(
        spec.name,
        spec.version.to_s,
        options.merge(
          summary: spec.summary,
          description: spec.description,
          homepage: spec.homepage,
          children: spec.dependencies.map(&:name),
          groups: Array(bundler_def && bundler_def.groups),
          spec_licenses: spec.licenses
        )
      )
      @gem_def = spec
    end

    private

    def install_path
      gem_def.full_gem_path
    end
  end
end
