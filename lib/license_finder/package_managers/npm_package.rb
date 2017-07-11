module LicenseFinder
  class NpmPackage < Package
    def initialize(spec, options={})
      super(
        spec["name"],
        spec["version"],
        options.merge(
          description: spec["description"],
          homepage: spec["homepage"],
          spec_licenses: spec["licenses"],
          install_path: spec["path"],
          children: spec.fetch("dependencies", {}).map { |_, d| d["name"] }
        )
      )
    end

    def package_manager
      'Npm'
    end
  end
end
