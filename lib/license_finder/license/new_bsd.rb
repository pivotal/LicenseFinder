class LicenseFinder::License::NewBSD < LicenseFinder::License::Base
  self.pretty_name       = "New BSD"
  self.alternative_names = ["Modified BSD", "BSD3", "BSD-3", "3-clause BSD", "BSD-3-Clause"]
  self.license_url       = "http://opensource.org/licenses/BSD-3-Clause"

  ALTERNATE_LICENSE_REGEX = compile_text_to_regex(
    license_text.gsub(
      "Neither the name of <organization> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.",
      "The names of its contributors may not be used to endorse or promote products derived from this software without specific prior written permission."
    )
  )

  def matches?
    super || matches_alternate?
  end

  private

  def matches_alternate?
    text_matches? ALTERNATE_LICENSE_REGEX
  end
end
