module LicenseFinder
  class CocoaPodsPackage < Package
    def initialize(name, version, license_text, options={})
      super(name, version, options)
      @license_text = license_text
    end

    def licenses
      [License.find_by_text(@license_text.to_s) || default_license].to_set
    end
  end
end
