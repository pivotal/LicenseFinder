module LicenseFinder
  class PipPackage < Package
    LICENSE_FORMAT = /^License.*::\s*(.*)$/

    def self.license_names_from_spec(spec)
      license = spec["license"]

      return [license] if license && license != "UNKNOWN"

      spec
        .fetch("classifiers", [])
        .select { |c| c =~ LICENSE_FORMAT }
        .map { |c| c.gsub(LICENSE_FORMAT, '\1') }
    end

    def initialize(name, version, spec, options={})
      super(
        name,
        version,
        options.merge(
          summary: spec["summary"],
          description: spec["description"],
          homepage: spec["home_page"],
          spec_licenses: self.class.license_names_from_spec(spec)
        )
      )
    end
  end
end
