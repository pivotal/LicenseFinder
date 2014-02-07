class LicenseFinder::License
  new_bsd_template = Template.named("NewBSD")
  new_bsd_alternate_content = new_bsd_template.content.gsub(
    "Neither the name of <organization> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.",
    "The names of its contributors may not be used to endorse or promote products derived from this software without specific prior written permission."
  )
  new_bsd_matcher = AnyMatcher.new(
    TemplateMatcher.new(new_bsd_template),
    TextMatcher.new(new_bsd_alternate_content)
  )

  all << new(
    short_name:  "NewBSD",
    pretty_name: "New BSD",
    other_names: ["Modified BSD", "BSD3", "BSD-3", "3-clause BSD", "BSD-3-Clause"],
    url:         "http://opensource.org/licenses/BSD-3-Clause",
    matcher:     new_bsd_matcher
  )
end
