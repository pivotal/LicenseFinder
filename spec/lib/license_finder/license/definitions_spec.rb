# frozen_string_literal: true

require 'spec_helper'

describe LicenseFinder::License::Definitions do
  it 'should create unrecognized licenses' do
    license = described_class.build_unrecognized('foo')
    expect(license.name).to eq('foo')
    expect(license.url).to be_nil
    expect(license).to be_matches_name('foo')
    expect(license).not_to be_matches_text('foo')
  end
end

describe LicenseFinder::License, 'Apache1.1' do
  subject { described_class.find_by_name 'Apache1_1' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://www.apache.org/licenses/LICENSE-1.1.txt'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('Apache-1.1')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('Apache 1.1')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('Apache Software License, Version 1.1')).to be subject
    expect(described_class.find_by_name('The Apache Software License, Version 1.1')).to be subject
  end
end

describe LicenseFinder::License, 'Apache2' do
  subject { described_class.find_by_name 'Apache2' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://www.apache.org/licenses/LICENSE-2.0.txt'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('Apache-2.0')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('Apache 2.0')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('Apache License')).to be subject
    expect(described_class.find_by_name('Apache Software License')).to be subject
    expect(described_class.find_by_name('Apache 2')).to be subject
    expect(described_class.find_by_name('Apache License, Version 2.0')).to be subject
    expect(described_class.find_by_name('The Apache License, Version 2.0')).to be subject
    expect(described_class.find_by_name('ASL 2.0')).to be subject
    expect(described_class.find_by_name('ASF 2.0')).to be subject
  end
end

describe LicenseFinder::License, 'BSD' do
  subject { described_class.find_by_name 'BSD' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://en.wikipedia.org/wiki/BSD_licenses#4-clause_license_.28original_.22BSD_License.22.29'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('BSD-4-Clause')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('bsd-old')).to be subject
    expect(described_class.find_by_name('BSD 4-Clause')).to be subject
    expect(described_class.find_by_name('BSD License')).to be subject
    expect(described_class.find_by_name('The BSD License')).to be subject
  end
end

describe LicenseFinder::License, 'cc01' do
  subject { described_class.find_by_name 'CC01' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://creativecommons.org/publicdomain/zero/1.0'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('CC0-1.0')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('CC0 1.0 Universal')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('CC0 1.0')).to be subject
  end
end

describe LicenseFinder::License, 'CDDL1' do
  subject { described_class.find_by_name 'CDDL1' }

  it 'should have correct license url' do
    expect(subject.url).to be 'https://spdx.org/licenses/CDDL-1.0.html'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('CDDL-1.0')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('Common Development and Distribution License 1.0')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('CDDL-1.0')).to be subject
    expect(described_class.find_by_name('Common Development and Distribution License (CDDL) v1.0')).to be subject
    expect(described_class.find_by_name('COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0')).to be subject
  end
end

describe LicenseFinder::License, 'EPL1' do
  subject { described_class.find_by_name 'EPL1' }

  it 'should have correct license url' do
    expect(subject.url).to be 'https://www.eclipse.org/legal/epl-v10.html'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('EPL-1.0')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('Eclipse Public License 1.0')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('EPL 1.0')).to be subject
    expect(described_class.find_by_name('Eclipse Public License - v 1.0')).to be subject
  end
end

describe LicenseFinder::License, 'GPLv2' do
  subject { described_class.find_by_name 'GPLv2' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://www.gnu.org/licenses/gpl-2.0.txt'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('GPL-2.0-only')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('GPL V2')).to be subject
    expect(described_class.find_by_name('gpl-v2')).to be subject
    expect(described_class.find_by_name('GNU GENERAL PUBLIC LICENSE Version 2')).to be subject
  end
end

describe LicenseFinder::License, 'GPLv3' do
  subject { described_class.find_by_name 'GPLv3' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://www.gnu.org/licenses/gpl-3.0.txt'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('GPL-3.0-only')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('GPL V3')).to be subject
    expect(described_class.find_by_name('gpl-v3')).to be subject
    expect(described_class.find_by_name('GNU GENERAL PUBLIC LICENSE Version 3')).to be subject
  end
end

describe LicenseFinder::License, 'ISC' do
  subject { described_class.find_by_name 'ISC' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://en.wikipedia.org/wiki/ISC_license'
  end
end

describe LicenseFinder::License, 'LGPL' do
  subject { described_class.find_by_name 'LGPL' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://www.gnu.org/licenses/lgpl.txt'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('LGPL-3.0-only')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('LGPL-3')).to be subject
    expect(described_class.find_by_name('LGPLv3')).to be subject
    expect(described_class.find_by_name('LGPL-3.0')).to be subject
  end
end

describe LicenseFinder::License, 'LGPL2.1' do
  subject { described_class.find_by_name 'LGPL2_1' }

  it 'should have correct license url' do
    expect(subject.url).to be 'https://opensource.org/licenses/LGPL-2.1'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('LGPL-2.1-only')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('LGPL 2.1')).to be subject
    expect(described_class.find_by_name('LGPL v2.1')).to be subject
    expect(described_class.find_by_name('GNU Lesser General Public License 2.1')).to be subject
  end
end

describe LicenseFinder::License, 'MIT' do
  subject { described_class.find_by_name 'MIT' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://opensource.org/licenses/mit-license'
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('Expat')).to be subject
    expect(described_class.find_by_name('MIT license')).to be subject
    expect(described_class.find_by_name('MIT License')).to be subject
    expect(described_class.find_by_name('MIT License (MIT)')).to be subject
    expect(described_class.find_by_name('The MIT License (MIT)')).to be subject
  end

  describe '#matches_text?' do
    it 'should return true if the text contains the MIT url' do
      expect(subject).to be_matches_text 'MIT License is awesome http://opensource.org/licenses/mit-license'

      expect(subject).to be_matches_text 'MIT Licence is awesome http://www.opensource.org/licenses/mit-license'

      expect(subject).not_to be_matches_text 'MIT Licence is awesome http://www!opensource!org/licenses/mit-license'
    end

    it "should return true if the text begins with 'The MIT License'" do
      expect(subject).to be_matches_text 'The MIT License'

      expect(subject).to be_matches_text 'The MIT Licence'

      expect(subject).not_to be_matches_text "Something else\nThe MIT License"
    end

    it "should return true if the text contains 'is released under the MIT license'" do
      expect(subject).to be_matches_text 'is released under the MIT license'

      expect(subject).to be_matches_text 'is released under the MIT licence'
    end
  end
end

describe LicenseFinder::License, 'MPL1_1' do
  subject { described_class.find_by_name 'MPL1_1' }

  it 'should have correct license url' do
    expect(subject.url).to be 'https://www.mozilla.org/media/MPL/1.1/index.0c5913925d40.txt'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('MPL-1.1')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('Mozilla Public License 1.1')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('Mozilla Public License, Version 1.1')).to be subject
    expect(described_class.find_by_name('Mozilla Public License version 1.1')).to be subject
  end

  describe '#matches_text?' do
    it "should return true if the text begins with 'Mozilla Public License Version 1.1'" do
      expect(subject).to be_matches_text 'Mozilla Public License Version 1.1'
      expect(subject).to be_matches_text 'Mozilla Public License, Version 1.1'
      expect(subject).to be_matches_text 'Mozilla Public Licence Version 1.1'
    end

    it "should return false if the text beings with 'Mozilla Public License, version 2.0'" do
      expect(subject).not_to be_matches_text 'Mozilla Public License version 2.0'
      expect(subject).not_to be_matches_text 'Mozilla Public License, version 2.0'
      expect(subject).not_to be_matches_text 'Mozilla Public Licence version 2.0'
    end
  end
end

describe LicenseFinder::License, 'MPL2' do
  subject { described_class.find_by_name 'MPL2' }

  it 'should have correct license url' do
    expect(subject.url).to be 'https://www.mozilla.org/media/MPL/2.0/index.815ca599c9df.txt'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('MPL-2.0')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('Mozilla Public License 2.0')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('Mozilla Public License, Version 2.0')).to be subject
    expect(described_class.find_by_name('Mozilla Public License version 2.0')).to be subject
  end

  describe '#matches_text?' do
    it "should return true if the text begins with 'The Mozilla Public License, version 2.0'" do
      expect(subject).to be_matches_text 'Mozilla Public License, version 2.0'

      expect(subject).not_to be_matches_text "Something else\nMozilla Public License, version 2.0"
    end
  end
end

describe LicenseFinder::License, 'NewBSD' do
  subject { described_class.find_by_name 'NewBSD' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://opensource.org/licenses/BSD-3-Clause'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('BSD-3-Clause')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('New BSD')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('Modified BSD')).to be subject
    expect(described_class.find_by_name('BSD3')).to be subject
    expect(described_class.find_by_name('BSD 3')).to be subject
    expect(described_class.find_by_name('BSD-3')).to be subject
    expect(described_class.find_by_name('3-clause BSD')).to be subject
    expect(described_class.find_by_name('3-Clause BSD License')).to be subject
    expect(described_class.find_by_name('BSD 3-Clause')).to be subject
    expect(described_class.find_by_name('BSD 3-Clause License')).to be subject
    expect(described_class.find_by_name('The 3-Clause BSD License')).to be subject
    expect(described_class.find_by_name('BSD 3-clause New License')).to be subject
    expect(described_class.find_by_name('New BSD License')).to be subject
    expect(described_class.find_by_name('BSD New license')).to be subject
    expect(described_class.find_by_name('BSD Licence 3')).to be subject
  end

  it 'should match regardless of organization or copyright holder names' do
    license = <<-LICENSE
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Johnny %$#!.43298432, Guitar INC! nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Johnny %$#!.43298432, Guitar BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    LICENSE

    expect(subject).to be_matches_text license
  end

  it 'should match with the alternate wording of third clause' do
    license = <<-LICENSE
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * The names of its contributors may not be used to endorse or promote
      products derived from this software without specific prior written
      permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Johnny %$#!.43298432, Guitar BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    LICENSE

    expect(subject).to be_matches_text license
  end
end

describe LicenseFinder::License, 'OFL' do
  subject { described_class.find_by_name 'OFL' }

  it 'should have correct license url' do
    expect(subject.url).to be 'https://opensource.org/licenses/OFL-1.1'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('OFL-1.1')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('SIL OPEN FONT LICENSE Version 1.1')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('OPEN FONT LICENSE Version 1.1')).to be subject
  end
end

describe LicenseFinder::License, 'Python' do
  subject { described_class.find_by_name 'Python' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://hg.python.org/cpython/raw-file/89ce323357db/LICENSE'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('PSF-2.0')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('Python Software Foundation License')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('PSF')).to be subject
    expect(described_class.find_by_name('PSFL')).to be subject
    expect(described_class.find_by_name('PSF License')).to be subject
  end
end

describe LicenseFinder::License, 'Ruby' do
  subject { described_class.find_by_name 'Ruby' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://www.ruby-lang.org/en/LICENSE.txt'
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('ruby')).to be subject
  end

  describe '#matches?' do
    it 'should return true when the Ruby license URL is present' do
      expect(subject).to be_matches_text "This gem is available under the following license:\nhttp://www.ruby-lang.org/en/LICENSE.txt\nOkay?"
    end

    it 'should return false when the Ruby License URL is not present' do
      expect(subject).not_to be_matches_text "This gem is available under the following license:\nhttp://www.example.com\nOkay?"
    end

    it 'should return false for pathological licenses' do
      expect(subject).not_to be_matches_text "This gem is available under the following license:\nhttp://wwwzruby-langzorg/en/LICENSEztxt\nOkay?"
    end
  end
end

describe LicenseFinder::License, 'SimplifiedBSD' do
  subject { described_class.find_by_name 'SimplifiedBSD' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://opensource.org/licenses/bsd-license'
  end

  it 'should be recognized by spdx_id' do
    expect(described_class.find_by_name('BSD-2-Clause')).to be subject
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('Simplified BSD')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('FreeBSD')).to be subject
    expect(described_class.find_by_name('2-clause BSD')).to be subject
    expect(described_class.find_by_name('BSD 2-Clause')).to be subject
    expect(described_class.find_by_name('BSD 2-Clause License')).to be subject
    expect(described_class.find_by_name('The BSD 2-Clause License')).to be subject
  end
end

describe LicenseFinder::License, 'Unlicense' do
  subject { described_class.find_by_name 'Unlicense' }

  it 'should have correct license url' do
    expect(subject.url).to be 'https://unlicense.org/'
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('The Unlicense')).to be subject
  end
end

describe LicenseFinder::License, 'WTFPL' do
  subject { described_class.find_by_name 'WTFPL' }

  it 'should have correct license url' do
    expect(subject.url).to be 'http://www.wtfpl.net/'
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('WTFPL V2')).to be subject
    expect(described_class.find_by_name('Do What The Fuck You Want To Public License')).to be subject
  end
end

describe LicenseFinder::License, '0BSD' do
  subject { described_class.find_by_name '0BSD' }

  it 'should have correct license url' do
    expect(subject.url).to be 'https://opensource.org/licenses/0BSD'
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('BSD Zero Clause License')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('0-Clause BSD')).to be subject
    expect(described_class.find_by_name('Zero-Clause BSD')).to be subject
    expect(described_class.find_by_name('BSD-0-Clause')).to be subject
    expect(described_class.find_by_name('BSD-Zero-Clause')).to be subject
    expect(described_class.find_by_name('BSD 0-Clause')).to be subject
    expect(described_class.find_by_name('BSD Zero-Clause')).to be subject
  end
end

describe LicenseFinder::License, 'Zlib' do
  subject { described_class.find_by_name 'Zlib' }

  it 'should have correct license url' do
    expect(subject.url).to be 'https://opensource.org/licenses/Zlib'
  end

  it 'should be recognized by pretty name' do
    expect(described_class.find_by_name('zlib/libpng license')).to be subject
  end

  it 'should be recognised by other names' do
    expect(described_class.find_by_name('zlib License')).to be subject
  end

  it 'should match regardless of year or copyright holder names' do
    license = <<-LICENSE
SOFTWARE NAME - Copyright (c) 1995-2017 - COPYRIGHT HOLDER NAME

This software is provided 'as-is', without any express or
implied warranty. In no event will the authors be held
liable for any damages arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute
it freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented;
   you must not claim that you wrote the original software.
   If you use this software in a product, an acknowledgment
   in the product documentation would be appreciated but
   is not required.

2. Altered source versions must be plainly marked as such,
   and must not be misrepresented as being the original software.

3. This notice may not be removed or altered from any
   source distribution.
    LICENSE

    expect(subject).to be_matches_text license
    expect(subject).not_to be_matches_text 'SOME OTHER LICENSE'
  end
end
