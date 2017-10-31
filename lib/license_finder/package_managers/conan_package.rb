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
  end
end
