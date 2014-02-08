class LicenseFinder::License
  ruby_license_url = "http://www.ruby-lang.org/en/LICENSE.txt"
  ruby_url_regex = Regexp.new(Regexp.escape(ruby_license_url))
  ruby_matcher = AnyMatcher.new(
    Matcher.from_template(Template.named("Ruby")),
    Matcher.new(ruby_url_regex)
  )

  all << new(
    short_name:  "Ruby",
    pretty_name: "ruby",
    url:         ruby_license_url,
    matcher:     ruby_matcher
  )
end
