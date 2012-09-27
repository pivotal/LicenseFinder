module LicenseFinder::LicenseUrl
  extend self

  def find_by_name(name)
    name = name.to_s

    license = LicenseFinder::License.find_by_name(name)
    license.license_url if license
  end
end
