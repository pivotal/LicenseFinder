class LicenseFinder::License::MIT < LicenseFinder::License::Base
  self.alternative_names = ["Expat", "MIT license", "MIT License"]
  self.license_url       = "http://opensource.org/licenses/mit-license"

  HEADER_REGEX = /The MIT Licen[sc]e/
  ONE_LINER_REGEX = /is released under the MIT licen[sc]e/
  URL_REGEX = %r{MIT Licen[sc]e.*http://(?:www\.)?opensource\.org/licenses/mit-license}

  def matches?
    super || matches_url? || matches_header? || matches_one_liner?
  end

  private

  def matches_url?
    text_matches? URL_REGEX
  end

  def matches_header?
    header = text.split("\n").first || ''
    !!(header.strip =~ HEADER_REGEX)
  end

  def matches_one_liner?
    text_matches? ONE_LINER_REGEX
  end
end
