# frozen_string_literal: true

module LicenseFinder
  class License
    module Definitions
      extend self

      def all
        [
          apache1_1,
          apache2,
          bsd,
          cc01,
          cddl1,
          eclipse1,
          gplv2,
          gplv3,
          isc,
          lgpl,
          lgpl2_1,
          mit,
          mpl1_1,
          mpl2,
          newbsd,
          ofl,
          python,
          ruby,
          simplifiedbsd,
          wtfpl,
          zerobsd
        ]
      end

      def build_unrecognized(name)
        License.new(
          short_name: name,
          url: nil,
          matcher: NoneMatcher.new
        )
      end

      private

      def apache1_1
        License.new(
          short_name: 'Apache1_1',
          pretty_name: 'Apache 1.1',
          other_names: [
            'Apache-1.1',
            'The Apache Software License, Version 1.1'
          ],
          url: 'http://www.apache.org/licenses/LICENSE-1.1.txt'
        )
      end

      def apache2
        License.new(
          short_name: 'Apache2',
          pretty_name: 'Apache 2.0',
          other_names: [
            'Apache-2.0',
            'Apache Software License',
            'Apache License 2.0',
            'Apache License Version 2.0',
            'Apache Public License 2.0',
            'Apache Software License, Version 2.0',
            'Apache Software License - Version 2.0',
            'Apache 2',
            'Apache License',
            'Apache License, Version 2.0',
            'ASL 2.0',
            'ASF 2.0'
          ],
          url: 'http://www.apache.org/licenses/LICENSE-2.0.txt'
        )
      end

      def bsd
        License.new(
          short_name: 'BSD',
          other_names: ['BSD4', 'bsd-old', '4-clause BSD', 'BSD-4-Clause', 'BSD 4-Clause', 'BSD License'],
          url: 'http://en.wikipedia.org/wiki/BSD_licenses#4-clause_license_.28original_.22BSD_License.22.29'
        )
      end

      def cc01
        License.new(
          short_name: 'CC01',
          pretty_name: 'CC0 1.0 Universal',
          other_names: ['CC0 1.0'],
          url: 'http://creativecommons.org/publicdomain/zero/1.0'
        )
      end

      def cddl1
        License.new(
          short_name: 'CDDL1',
          pretty_name: 'Common Development and Distribution License 1.0',
          other_names: [
            'CDDL-1.0',
            'Common Development and Distribution License (CDDL) v1.0',
            'COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0'
          ],
          url: 'https://spdx.org/licenses/CDDL-1.0.html'
        )
      end

      def eclipse1
        License.new(
          short_name: 'EPL1',
          pretty_name: 'Eclipse Public License 1.0',
          other_names: [
            'EPL-1.0',
            'EPL 1.0',
            'Eclipse Public License - v 1.0'
          ],
          url: 'https://www.eclipse.org/legal/epl-v10.html'
        )
      end

      def gplv2
        License.new(
          short_name: 'GPLv2',
          other_names: ['GPL V2', 'gpl-v2', 'GNU GENERAL PUBLIC LICENSE Version 2'],
          url: 'http://www.gnu.org/licenses/gpl-2.0.txt'
        )
      end

      def gplv3
        License.new(
          short_name: 'GPLv3',
          other_names: ['GPL V3', 'gpl-v3', 'GNU GENERAL PUBLIC LICENSE Version 3'],
          url: 'http://www.gnu.org/licenses/gpl-3.0.txt'
        )
      end

      def isc
        License.new(
          short_name: 'ISC',
          url: 'http://en.wikipedia.org/wiki/ISC_license'
        )
      end

      def lgpl
        License.new(
          short_name: 'LGPL',
          other_names: ['LGPL-3', 'LGPLv3', 'LGPL-3.0'],
          url: 'http://www.gnu.org/licenses/lgpl.txt'
        )
      end

      def lgpl2_1
        License.new(
          short_name: 'LGPL2_1',
          pretty_name: 'GNU Lesser General Public License version 2.1',
          other_names: [
            'LGPL-2.1-only',
            'LGPL 2.1',
            'LGPL v2.1',
            'GNU Lesser General Public License 2.1'
          ],
          url: 'https://opensource.org/licenses/LGPL-2.1'
        )
      end

      def mit
        url_regexp = %r{MIT Licen[sc]e.*http://(?:www\.)?opensource\.org/licenses/mit-license}
        header_regexp = /The MIT Licen[sc]e/
        one_liner_regexp = /is released under the MIT licen[sc]e/

        matcher = AnyMatcher.new(
          Matcher.from_template(Template.named('MIT')),
          Matcher.from_regex(url_regexp),
          HeaderMatcher.new(Matcher.from_regex(header_regexp)),
          Matcher.from_regex(one_liner_regexp)
        )

        License.new(
          short_name: 'MIT',
          other_names: ['Expat', 'MIT license', 'MIT License', 'The MIT License (MIT)'],
          url: 'http://opensource.org/licenses/mit-license',
          matcher: matcher
        )
      end

      def mpl1_1
        header_regexp = /Mozilla Public Licen[sc]e.*Version 1\.1/im

        header_regexp_matcher = Matcher.from_regex(header_regexp)
        mpl1_1_tmpl = Template.named('MPL1_1')

        matcher = AnyMatcher.new(
          HeaderMatcher.new(header_regexp_matcher, 2),
          Matcher.from_template(mpl1_1_tmpl)
        )

        License.new(
          short_name: 'MPL1_1',
          pretty_name: 'Mozilla Public License 1.1',
          other_names: [
            'MPL-1.1',
            'Mozilla Public License, Version 1.1',
            'Mozilla Public License version 1.1'
          ],
          url: 'https://www.mozilla.org/media/MPL/1.1/index.0c5913925d40.txt',
          matcher: matcher
        )
      end

      def mpl2
        header_regexp = /Mozilla Public Licen[sc]e, version 2\.0/

        matcher = AnyMatcher.new(
          Matcher.from_template(Template.named('MPL2')),
          HeaderMatcher.new(Matcher.from_regex(header_regexp))
        )

        License.new(
          short_name: 'MPL2',
          pretty_name: 'Mozilla Public License 2.0',
          other_names: [
            'MPL-2.0',
            'Mozilla Public License, Version 2.0',
            'Mozilla Public License version 2.0'
          ],
          url: 'https://www.mozilla.org/media/MPL/2.0/index.815ca599c9df.txt',
          matcher: matcher
        )
      end

      def newbsd
        template = Template.named('NewBSD')
        alternate_content = template.content.gsub(
          'Neither the name of <organization> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.',
          'The names of its contributors may not be used to endorse or promote products derived from this software without specific prior written permission.'
        )

        matcher = AnyMatcher.new(
          Matcher.from_template(template),
          Matcher.from_text(alternate_content)
        )

        License.new(
          short_name: 'NewBSD',
          pretty_name: 'New BSD',
          other_names: [
            'Modified BSD',
            'BSD3',
            'BSD 3',
            'BSD-3',
            '3-clause BSD',
            'BSD-3-Clause',
            'BSD 3-Clause License',
            'The 3-Clause BSD License',
            'BSD 3-clause New License',
            'New BSD License',
            'BSD New license',
            'BSD Licence 3'
          ],
          url: 'http://opensource.org/licenses/BSD-3-Clause',
          matcher: matcher
        )
      end

      def ofl
        License.new(
          short_name: 'OFL',
          pretty_name: 'SIL OPEN FONT LICENSE Version 1.1',
          other_names: [
            'OPEN FONT LICENSE Version 1.1'
          ],
          url: 'https://opensource.org/licenses/OFL-1.1'
        )
      end

      def python
        License.new(
          short_name: 'Python',
          pretty_name: 'Python Software Foundation License',
          other_names: [
            'PSF',
            'PSFL',
            'PSF License'
          ],
          url: 'http://hg.python.org/cpython/raw-file/89ce323357db/LICENSE'
        )
      end

      def ruby
        url = 'http://www.ruby-lang.org/en/LICENSE.txt'

        matcher = AnyMatcher.new(
          Matcher.from_template(Template.named('Ruby')),
          Matcher.from_text(url)
        )

        License.new(
          short_name: 'Ruby',
          pretty_name: 'ruby',
          url: url,
          matcher: matcher
        )
      end

      def simplifiedbsd
        License.new(
          short_name: 'SimplifiedBSD',
          pretty_name: 'Simplified BSD',
          other_names: [
            'FreeBSD',
            '2-clause BSD',
            'BSD-2-Clause',
            'BSD 2-Clause',
            'The BSD 2-Clause License'
          ],
          url: 'http://opensource.org/licenses/bsd-license'
        )
      end

      def wtfpl
        License.new(
          short_name: 'WTFPL',
          pretty_name: 'WTFPL',
          other_names: [
            'WTFPL V2',
            'Do What The Fuck You Want To Public License'
          ],
          url: 'http://www.wtfpl.net/'
        )
      end

      def zerobsd
        matcher = AnyMatcher.new(
          Matcher.from_template(Template.named('0BSD'))
        )

        License.new(
          short_name: '0BSD',
          pretty_name: 'BSD Zero Clause License',
          other_names: [
            '0-Clause BSD',
            'Zero-Clause BSD',
            'BSD-0-Clause',
            'BSD-Zero-Clause',
            'BSD 0-Clause',
            'BSD Zero-Clause'
          ],
          url: 'https://opensource.org/licenses/0BSD',
          matcher: matcher
        )
      end
    end
  end
end
