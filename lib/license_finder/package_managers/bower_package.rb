module LicenseFinder
  class BowerPackage < Package
    def initialize(bower_module, options={})
      @bower_module = bower_module
      module_metadata = bower_module.fetch("pkgMeta", Hash.new)

      super(
        module_metadata.fetch("name", nil),
        module_metadata.fetch("version", nil),
        options.merge(
          summary: module_metadata.fetch("description", nil),
          description: module_metadata.fetch("readme", nil),
          homepage: module_metadata.fetch("homepage", nil),
          spec_licenses: Package.license_names_from_standard_spec(module_metadata)
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
