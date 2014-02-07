class LicenseFinder::License
  ruby_license_url = "http://www.ruby-lang.org/en/LICENSE.txt"
  ruby_url_regex = Regexp.new(Regexp.escape(ruby_license_url))
  ruby_matcher = AnyMatcher.new(
    TemplateMatcher.new(Template.named("Ruby")),
    RegexpMatcher.new(ruby_url_regex)
  )

  all << new(
    demodulized_name:  "Ruby",
    pretty_name:       "ruby",
    license_url:       ruby_license_url,
    matching_algorithm: ruby_matcher
  )
end
