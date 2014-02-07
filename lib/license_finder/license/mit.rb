class LicenseFinder::License
  mit_header_regexp = /The MIT Licen[sc]e/
  mit_one_liner_regexp = /is released under the MIT licen[sc]e/
  mit_url_regexp = %r{MIT Licen[sc]e.*http://(?:www\.)?opensource\.org/licenses/mit-license}

  mit_matcher = AnyMatcher.new(
    TemplateMatcher.new(Template.named("MIT")),
    RegexpMatcher.new(mit_url_regexp),
    HeaderMatcher.new(RegexpMatcher.new(mit_header_regexp)),
    RegexpMatcher.new(mit_one_liner_regexp)
  )

  all << new(
    demodulized_name:  "MIT",
    alternative_names: ["Expat", "MIT license", "MIT License"],
    license_url:       "http://opensource.org/licenses/mit-license",
    matching_algorithm: mit_matcher
  )
end
