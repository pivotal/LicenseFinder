class LicenseFinder::License::Ruby < LicenseFinder::License::Base
  self.pretty_name = "ruby"
  self.license_url = "http://www.ruby-lang.org/en/LICENSE.txt"

  URL_REGEX = Regexp.new(Regexp.escape(license_url))

  def matches?
    super || matches_url?
  end

  private

  def matches_url?
    text_matches? URL_REGEX
  end
end
