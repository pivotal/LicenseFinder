# frozen_string_literal: true

require 'set'

module LicenseFinder
  class PipPackage < Package
    LICENSE_FORMAT = /^License.*::\s*(.*)$/.freeze
    INVALID_LICENSES = ['', 'UNKNOWN'].to_set

    def self.license_names_from_spec(spec)
      license_names = spec['license'].to_s.strip.split(' or ')
      has_unrecognized_license = false

      license_names.each do |license_name|
        license = License.find_by_name(license_name.strip)

        has_unrecognized_license ||= license.unrecognized_matcher?
      end

      return license_names if !license_names.empty? && !has_unrecognized_license

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

    def package_url
      "https://pypi.org/project/#{CGI.escape(name)}/#{CGI.escape(version)}/"
    end
  end
end
