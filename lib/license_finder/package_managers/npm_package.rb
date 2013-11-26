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

    def children
      [] # no way to determine child deps from npm (maybe?)
    end

    def groups
      [] # no concept of dev/test groups in npm (maybe?)
    end

    def homepage
      nil # no way to extract homepage from npm (maybe?)
    end

    private

    attr_reader :node_module

    def install_path
      node_module["path"]
    end

    def license_from_spec
      license = node_module.fetch("licenses", []).first

      if license
        license = license.fetch("type", nil)
      end

      if license.nil?
        license = node_module.fetch("license", nil)

        if license.is_a? Hash
          license = license.fetch("type", nil)
        end
      end

      license
    end
  end
end
