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

    def children
      [] # no way to determine child deps from pip (maybe?)
    end

    def groups
      [] # no concept of dev/test groups in pip (maybe?)
    end

    def homepage
      nil # no way to extract homepage from pip (maybe?)
    end

    private

    attr_reader :install_path, :pypi_def

    def license_from_spec
      license = pypi_def.fetch("license", "UNKNOWN")

      if license == "UNKNOWN"
        classifiers = pypi_def.fetch("classifiers", [])
        license = classifiers.map do |c|
          if c.start_with?("License")
            c.gsub(/^License.*::\s*(.*)$/, '\1')
          end
        end.compact.first
      end

      license
    end
  end
end
