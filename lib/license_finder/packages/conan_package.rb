# frozen_string_literal: true

module LicenseFinder
  class ConanPackage < Package
    def initialize(name, version, license_text, url, options = {})
      super(name, version, options)
      @license = License.find_by_text(license_text.to_s)
      @homepage = url
    end

    def licenses_from_spec
      [@license].compact
    end

    def package_manager
      'Conan'
    end

    def package_url
      "https://conan.io/center/#{CGI.escape(name)}/#{CGI.escape(version)}"
    end
  end
end
