module LicenseFinder
  class PipPackage < Package
    def initialize(name, version, install_path, pypi_def)
      @name = name
      @version = version
      @install_path = install_path
      @pypi_def = pypi_def
    end

    attr_reader :name, :version

    def summary
      pypi_def.fetch("summary", "")
    end

    def description
      pypi_def.fetch("description", "")
    end

    def homepage
      pypi_def["home_page"]
    end

    def children
      [] # no way to determine child deps from pip (maybe?)
    end

    def groups
      [] # no concept of dev/test groups in pip (maybe?)
    end

    private

    attr_reader :install_path, :pypi_def

    def license_names_from_spec
      license = pypi_def["license"]

      return [license] if license && license != "UNKNOWN"

      pypi_def.
        fetch("classifiers", []).
        select { |c| c.start_with?("License") }.
        map { |c| c.gsub(/^License.*::\s*(.*)$/, '\1') }
    end
  end
end
