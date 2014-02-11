class LicenseFinder::License
  def self.mit_matcher
    url_regexp = %r{MIT Licen[sc]e.*http://(?:www\.)?opensource\.org/licenses/mit-license}
    header_regexp = /The MIT Licen[sc]e/
    one_liner_regexp = /is released under the MIT licen[sc]e/

    AnyMatcher.new(
      Matcher.from_template(Template.named("MIT")),
      Matcher.new(url_regexp),
      HeaderMatcher.new(Matcher.new(header_regexp)),
      Matcher.new(one_liner_regexp)
    )
  end

  def self.new_bsd_matcher
    template = Template.named("NewBSD")
    alternate_content = template.content.gsub(
      "Neither the name of <organization> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.",
      "The names of its contributors may not be used to endorse or promote products derived from this software without specific prior written permission."
    )

    AnyMatcher.new(
      Matcher.from_template(template),
      Matcher.from_text(alternate_content)
    )
  end

  def self.ruby_license_url
    "http://www.ruby-lang.org/en/LICENSE.txt"
  end

  def self.ruby_matcher
    url_regex = Regexp.new(Regexp.escape(ruby_license_url))

    AnyMatcher.new(
      Matcher.from_template(Template.named("Ruby")),
      Matcher.new(url_regex)
    )
  end

  all << new(
    short_name:  "Apache2",
    pretty_name: "Apache 2.0",
    other_names: ["Apache-2.0", "Apache Software License", "Apache License 2.0", "Apache License Version 2.0", "Apache Public License 2.0"],
    url:         "http://www.apache.org/licenses/LICENSE-2.0.txt"
  )

  all << new(
    short_name:  "BSD",
    other_names: ["BSD4", "bsd-old", "4-clause BSD", "BSD-4-Clause", "BSD License"],
    url:         "http://en.wikipedia.org/wiki/BSD_licenses#4-clause_license_.28original_.22BSD_License.22.29"
  )

  all << new(
    short_name:  "GPLv2",
    other_names: ["GPL V2", "gpl-v2", "GNU GENERAL PUBLIC LICENSE Version 2"],
    url:         "http://www.gnu.org/licenses/gpl-2.0.txt"
  )

  all << new(
    short_name: "ISC",
    url:        "http://en.wikipedia.org/wiki/ISC_license"
  )

  all << new(
    short_name:  "LGPL",
    other_names: ["LGPL-3", "LGPLv3", "LGPL-3.0"],
    url:         "http://www.gnu.org/licenses/lgpl.txt"
  )

  all << new(
    short_name:  "MIT",
    other_names: ["Expat", "MIT license", "MIT License"],
    url:         "http://opensource.org/licenses/mit-license",
    matcher:     mit_matcher
  )

  all << new(
    short_name:  "NewBSD",
    pretty_name: "New BSD",
    other_names: ["Modified BSD", "BSD3", "BSD-3", "3-clause BSD", "BSD-3-Clause"],
    url:         "http://opensource.org/licenses/BSD-3-Clause",
    matcher:     new_bsd_matcher
  )

  all << new(
    short_name:  "Python",
    pretty_name: "Python Software Foundation License",
    other_names: ["PSF"],
    url:         "http://hg.python.org/cpython/raw-file/89ce323357db/LICENSE"
  )

  all << new(
    short_name:  "Ruby",
    pretty_name: "ruby",
    url:         ruby_license_url,
    matcher:     ruby_matcher
  )

  all << new(
    short_name:  "SimplifiedBSD",
    pretty_name: "Simplified BSD",
    other_names: ["FreeBSD", "2-clause BSD", "BSD-2-Clause"],
    url:         "http://opensource.org/licenses/bsd-license"
  )
end
