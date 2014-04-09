module LicenseFinder
  class BowerPackage < Package
    def initialize(bower_module)
      @bower_module = bower_module
      @module_metadata = bower_module.fetch("pkgMeta", Hash.new)
    end

    def name
      module_metadata.fetch("name", nil)
    end

    def version
      module_metadata.fetch("version", nil)
    end

    def summary
      module_metadata.fetch("description", nil)
    end

    def description
      module_metadata.fetch("readme", nil)
    end

    def homepage
      module_metadata.fetch("homepage", nil)
    end

    def children
      [] # no way to determine child deps from bower (maybe?)
    end

    def groups
      [] # no concept of dev/test groups in bower (maybe?)
    end

    private

    attr_reader :bower_module
    attr_reader :module_metadata

    def install_path
      bower_module["canonicalDir"]
    end

    def license_names_from_spec
      Package.license_names_from_standard_spec(module_metadata)
    end
  end
end
