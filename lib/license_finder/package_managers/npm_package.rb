module LicenseFinder
  class NpmPackage < Package
    def initialize(node_module, options={})
      @node_module = node_module
      super(
        node_module["name"],
        node_module["version"],
        options.merge(
          summary: node_module["description"],
          description: node_module["readme"],
          homepage: node_module["homepage"],
          spec_licenses: Package.license_names_from_standard_spec(node_module)
        )
      )
    end

    private

    def install_path
      @node_module["path"]
    end
  end
end
