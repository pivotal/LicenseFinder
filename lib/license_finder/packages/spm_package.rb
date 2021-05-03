# frozen_string_literal: true

module LicenseFinder
  class SpmPackage < Package
    def initialize(name, version, license_text, options = {})
      super(name, version, options)
      @license = License.find_by_text(license_text.to_s)
    end

    def licenses_from_spec
      [@license].compact
    end

    def package_manager
      'Spm'
    end
  end
end
