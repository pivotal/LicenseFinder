class LicenseFinder::License::Ruby < LicenseFinder::License::Base
  URL_REGEX = %r{http://www.ruby-lang.org/en/LICENSE.txt}

  def self.pretty_name
    'ruby'
  end

  def matches?
    super || !!(text =~ URL_REGEX)
  end
end
