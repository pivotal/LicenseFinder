class LicenseFinder::License::MIT < LicenseFinder::License::Base
  HEADER_REGEX = /The MIT License/
  ONE_LINER_REGEX = /is released under the MIT license/
  URL_REGEX = %r{MIT Licence.*http://www.opensource.org/licenses/mit-license}

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
