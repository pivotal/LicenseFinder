module LicenseFinder
  class NpmPackage < Package
    def initialize(node_module)
      @node_module = node_module
    end

    def name
      node_module["name"]
    end

    def version
      node_module["version"]
    end

    def summary
      node_module["description"]
    end

    def description
      node_module["readme"]
    end

    def homepage
      node_module["homepage"]
    end

    def children
      [] # no way to determine child deps from npm (maybe?)
    end

    def groups
      [] # no concept of dev/test groups in npm (maybe?)
    end

    private

    attr_reader :node_module

    def install_path
      node_module["path"]
    end

    def license_names_from_spec
      Package.license_names_from_standard_spec(node_module)
    end
  end
end
