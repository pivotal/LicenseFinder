module LicenseFinder
  class PipPackage < Package
    def initialize(name, version, install_path, pypi_def, options={})
      super(
        name,
        version,
        options.merge(
          summary: pypi_def.fetch("summary", ""),
          description: pypi_def.fetch("description", ""),
          homepage: pypi_def["home_page"]
        )
      )
      @install_path = install_path
      @pypi_def = pypi_def
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
