class LicenseFinder::License::MIT < LicenseFinder::License::Base
  self.license_url = "http://opensource.org/licenses/mit-license"
  self.alternative_names = ["Expat"]

  HEADER_REGEX = /The MIT Licen[sc]e/
  ONE_LINER_REGEX = /is released under the MIT licen[sc]e/
  URL_REGEX = %r{MIT Licen[sc]e.*http://(?:www.)?opensource.org/licenses/mit-license}

  def matches?
    super || matches_url? || matches_header?
  end

  private

  def matches_url?
    !!(text =~ URL_REGEX)
  end

  def matches_header?
    header = text.split("\n").first
    header && ((header.strip =~ HEADER_REGEX) || !!(text =~ ONE_LINER_REGEX))
  end
end
