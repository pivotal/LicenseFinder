class LicenseFinder::License::Ruby < LicenseFinder::License::Base
  self.license_url = "http://www.ruby-lang.org/en/LICENSE.txt"

  def self.pretty_name
    'ruby'
  end

  def matches?
    super || !!(text =~ /#{self.class.license_url}/)
  end
end
