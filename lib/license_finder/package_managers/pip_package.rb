module LicenseFinder
  class PipPackage < Package
    def self.license_names_from_spec(spec)
      license = spec["license"]

      return [license] if license && license != "UNKNOWN"

      spec.
        fetch("classifiers", []).
        select { |c| c.start_with?("License") }.
        map { |c| c.gsub(/^License.*::\s*(.*)$/, '\1') }
    end

    def initialize(name, version, install_path, spec, options={})
      super(
        name,
        version,
        options.merge(
          summary: spec["summary"],
          description: spec["description"],
          homepage: spec["home_page"],
          spec_licenses: self.class.license_names_from_spec(spec),
          install_path: install_path
        )
      )
    end
  end
end
