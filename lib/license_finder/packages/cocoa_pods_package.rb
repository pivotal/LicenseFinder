# frozen_string_literal: true

module LicenseFinder
  class CocoaPodsPackage < Package
    def initialize(name, version, acknowledgement, options = {})
      licenses = acknowledgement && acknowledgement['License']
      license_text = acknowledgement && acknowledgement['FooterText']

      spec_licenses = [licenses] if licenses && !licenses.empty?
      @parsed_license = License.find_by_text(license_text.to_s) if spec_licenses.nil?

      super(name, version, options.merge(spec_licenses: spec_licenses))
    end

    def licenses_from_spec
      return [@parsed_license].compact if @parsed_license

      super
    end

    def package_manager
      'CocoaPods'
    end

    def package_url
      "https://cocoapods.org/pods/#{CGI.escape(name)}"
    end
  end
end
