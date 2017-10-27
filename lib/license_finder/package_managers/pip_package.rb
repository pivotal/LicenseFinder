module LicenseFinder
  class PipPackage < Package
    LICENSE_FORMAT = /^License.*::\s*(.*)$/
    INVALID_LICENSES = ['', 'UNKNOWN'].to_set

    def self.license_names_from_spec(spec)
      license = spec['license'].to_s.strip

      return [license] unless INVALID_LICENSES.include?(license)

      spec
        .fetch('classifiers', [])
        .select { |c| c =~ LICENSE_FORMAT }
        .map { |c| c.gsub(LICENSE_FORMAT, '\1') }
    end

    def initialize(name, version, spec, options = {})
      super(
        name,
        version,
        options.merge(
          authors: spec['author'],
          summary: spec['summary'],
          description: spec['description'],
          homepage: spec['home_page'],
          spec_licenses: self.class.license_names_from_spec(spec)
        )
      )
    end

    def package_manager
      'Pip'
    end
  end
end
