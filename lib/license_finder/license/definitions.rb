module LicenseFinder
  class License
    module Definitions
      extend self

      def build_all(whitelist)
        [
          build_apache2,
          build_bsd,
          build_gplv2,
          build_isc,
          build_lgpl,
          build_mit,
          build_newbsd,
          build_python,
          build_ruby,
          build_simplified_bsd
        ].map { |license|
          whitelist_if_necessary(license, whitelist)
        }
      end

      def build_unrecognized(name, whitelist)
        result = License.new(
          short_name: name,
          url: nil,
          matcher: NoneMatcher.new
        )
        whitelist_if_necessary(result, whitelist)
      end

      def whitelist_if_necessary(license, whitelist)
        whitelisted = whitelist.any? { |name| license.matches_name? name }
        whitelisted ? license.whitelist : license
      end

      private

      def build_apache2
        License.new(
          short_name:  "Apache2",
          pretty_name: "Apache 2.0",
          other_names: ["Apache-2.0", "Apache Software License", "Apache License 2.0", "Apache License Version 2.0", "Apache Public License 2.0"],
          url:         "http://www.apache.org/licenses/LICENSE-2.0.txt"
        )
      end

      def build_bsd
        License.new(
          short_name:  "BSD",
          other_names: ["BSD4", "bsd-old", "4-clause BSD", "BSD-4-Clause", "BSD License"],
          url:         "http://en.wikipedia.org/wiki/BSD_licenses#4-clause_license_.28original_.22BSD_License.22.29"
        )
      end

      def build_gplv2
        License.new(
          short_name:  "GPLv2",
          other_names: ["GPL V2", "gpl-v2", "GNU GENERAL PUBLIC LICENSE Version 2"],
          url:         "http://www.gnu.org/licenses/gpl-2.0.txt"
        )
      end

      def build_isc
        License.new(
          short_name: "ISC",
          url:        "http://en.wikipedia.org/wiki/ISC_license"
        )
      end

      def build_lgpl
        License.new(
          short_name:  "LGPL",
          other_names: ["LGPL-3", "LGPLv3", "LGPL-3.0"],
          url:         "http://www.gnu.org/licenses/lgpl.txt"
        )
      end

      def build_mit
        url_regexp = %r{MIT Licen[sc]e.*http://(?:www\.)?opensource\.org/licenses/mit-license}
        header_regexp = /The MIT Licen[sc]e/
        one_liner_regexp = /is released under the MIT licen[sc]e/

        matcher = AnyMatcher.new(
          Matcher.from_template(Template.named("MIT")),
          Matcher.new(url_regexp),
          HeaderMatcher.new(Matcher.new(header_regexp)),
          Matcher.new(one_liner_regexp)
        )

        License.new(
          short_name:  "MIT",
          other_names: ["Expat", "MIT license", "MIT License"],
          url:         "http://opensource.org/licenses/mit-license",
          matcher:     matcher
        )
      end

      def build_newbsd
        template = Template.named("NewBSD")
        alternate_content = template.content.gsub(
          "Neither the name of <organization> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.",
          "The names of its contributors may not be used to endorse or promote products derived from this software without specific prior written permission."
        )

        matcher = AnyMatcher.new(
          Matcher.from_template(template),
          Matcher.from_text(alternate_content)
        )

        License.new(
          short_name:  "NewBSD",
          pretty_name: "New BSD",
          other_names: ["Modified BSD", "BSD3", "BSD-3", "3-clause BSD", "BSD-3-Clause"],
          url:         "http://opensource.org/licenses/BSD-3-Clause",
          matcher:     matcher
        )
      end

      def build_python
        License.new(
          short_name:  "Python",
          pretty_name: "Python Software Foundation License",
          other_names: ["PSF"],
          url:         "http://hg.python.org/cpython/raw-file/89ce323357db/LICENSE"
        )
      end

      def build_ruby
        url = "http://www.ruby-lang.org/en/LICENSE.txt"
        url_regex = Regexp.new(Regexp.escape(url))

        matcher = AnyMatcher.new(
          Matcher.from_template(Template.named("Ruby")),
          Matcher.new(url_regex)
        )

        License.new(
          short_name:  "Ruby",
          pretty_name: "ruby",
          url:         url,
          matcher:     matcher
        )
      end

      def build_simplified_bsd
        License.new(
          short_name:  "SimplifiedBSD",
          pretty_name: "Simplified BSD",
          other_names: ["FreeBSD", "2-clause BSD", "BSD-2-Clause"],
          url:         "http://opensource.org/licenses/bsd-license"
        )
      end
    end
  end
end
