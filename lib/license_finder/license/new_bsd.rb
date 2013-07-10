class LicenseFinder::License::NewBSD < LicenseFinder::License::Base
  self.license_url = "http://opensource.org/licenses/BSD-3-Clause"
  self.alternative_names = ["Modified BSD", "BSD3", "BSD-3", "3-clause BSD", "BSD-3-Clause"]

  def self.pretty_name
    'New BSD'
  end

  def matches?
    super || matches_alternate?
  end

  def matches_alternate?
    !!(text =~ alternate_license_regex)
  end

  def alternate_license_regex
    /#{Regexp.escape(alternate_license_text).gsub(/<[^<>]+>/, '(.*)')}/
  end

  def alternate_license_text
    self.class.license_text.gsub(
      "Neither the name of <organization> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.",
      "The names of its contributors may not be used to endorse or promote products derived from this software without specific prior written permission."
    )
  end
end
