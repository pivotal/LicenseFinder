class LicenseFinder::License::Python < LicenseFinder::License::Base
  self.alternative_names = ["PSF", "Python Software Foundation License"]
  self.license_url       = "http://hg.python.org/cpython/raw-file/89ce323357db/LICENSE"

  def self.pretty_name
    'Python Software Foundation License'
  end
end
