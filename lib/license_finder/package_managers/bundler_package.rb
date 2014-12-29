module LicenseFinder
  class BundlerPackage < Package
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
          spec_licenses: spec.licenses,
          install_path: spec.full_gem_path
        )
      )
    end
  end
end
