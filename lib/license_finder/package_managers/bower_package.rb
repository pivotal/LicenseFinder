module LicenseFinder
  class BowerPackage < Package
    def initialize(bower_module, options={})
      @bower_module = bower_module
      spec = bower_module.fetch("pkgMeta", Hash.new)

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

    attr_reader :bower_module

    def install_path
      bower_module["canonicalDir"]
    end
  end
end
