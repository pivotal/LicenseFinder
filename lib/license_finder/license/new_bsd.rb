class LicenseFinder::License::NewBSD < LicenseFinder::License::Base
  self.license_url = "http://opensource.org/licenses/BSD-3-Clause"
  self.alternative_names = ["Modified BSD", "BSD3", "BSD-3", "3-clause BSD", "BSD-3-Clause"]

  def self.pretty_name
    'New BSD'
  end
end
