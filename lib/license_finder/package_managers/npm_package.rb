module LicenseFinder
  class NpmPackage < Package
    def initialize(spec, options={})
      @node_module = spec
      super(
        spec["name"],
        spec["version"],
        options.merge(
          summary: spec["description"],
          description: spec["readme"],
          homepage: spec["homepage"],
          spec_licenses: Package.license_names_from_standard_spec(spec)
        )
      )
    end

    private

    def install_path
      @node_module["path"]
    end
  end
end
