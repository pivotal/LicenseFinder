module LicenseFinder
  class BundlerPackage < Package
    def initialize(spec, bundler_def, options={})
      children = spec.dependencies.map(&:name)
      groups = Array(bundler_def && bundler_def.groups).map(&:to_s)

      super(
        spec.name,
        spec.version.to_s,
        options.merge(
          authors: spec.authors.tr('[]', '')
          summary: spec.summary,
          description: spec.description,
          homepage: spec.homepage,
          children: children,
          groups: groups,
          spec_licenses: spec.licenses,
          install_path: spec.full_gem_path
        )
      )
    end
  end
end
