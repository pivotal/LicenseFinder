module LicenseFinder
  module LicenseUrl
    extend self

    def find_by_name(name)
      name = name.to_s

      license = License.find_by_name(name)
      license.license_url if license
    end
  end
end
