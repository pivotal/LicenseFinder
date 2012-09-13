class LicenseFinder::License::SimplifiedBSD < LicenseFinder::License::Base
  self.license_url = "http://opensource.org/licenses/bsd-license"
  self.alternative_names = ["Simplified BSD", "FreeBSD", "2-clause BSD"]

  def self.pretty_name
    'Simplified BSD'
  end
end
