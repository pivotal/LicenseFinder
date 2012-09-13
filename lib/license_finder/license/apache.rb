class LicenseFinder::License::Apache < LicenseFinder::License::Base
  self.alternative_names = ["Apache 2.0", "Apache2"]
  self.license_url       = "http://www.apache.org/licenses/LICENSE-2.0.txt"

  def self.pretty_name
    'Apache 2.0'
  end
end
