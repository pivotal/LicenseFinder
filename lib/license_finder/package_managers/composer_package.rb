module LicenseFinder
  class ComposerPackage < Package
    def initialize(spec, options={})
      super(
        spec["name"],
        spec["version"], # @todo what does spec give us about the package?
        options.merge(
          description: spec["description"],
          homepage: spec["homepage"],
          spec_licenses: Package.license_names_from_standard_spec(spec),
          install_path: spec["path"],
          children: spec.fetch("require", {}).map { |_, d| d["name"] }
        )
      )
    end

    def package_manager
      'Npm'
    end
  end
end
