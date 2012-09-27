module LicenseFinder
  class Configuration < LicenseFinder::Persistence::Configuration
    def whitelisted?(license_name)
      license = License.find_by_name(license_name) || license_name
      whitelisted_licenses.include? license
    end

    private
    def whitelisted_licenses
      whitelist.map do |license_name|
        LicenseFinder::License.find_by_name(license_name) || license_name
      end.compact
    end
  end
end
