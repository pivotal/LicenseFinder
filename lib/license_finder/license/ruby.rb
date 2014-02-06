class LicenseFinder::License::Ruby < LicenseFinder::License::Base
  self.license_url = "http://www.ruby-lang.org/en/LICENSE.txt"
  URL_REGEX = Regexp.new(license_url)

  def self.pretty_name
    'ruby'
  end

  def matches?
    super || matches_url?
  end

  private

  def matches_url?
    text_matches? URL_REGEX
  end
end
