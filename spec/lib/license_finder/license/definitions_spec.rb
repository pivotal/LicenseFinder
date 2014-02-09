require 'spec_helper'

describe LicenseFinder::License, "Apache2" do
  it "should be findable" do |e|
    described_class.find_by_name("Apache2").should be
  end
end

describe LicenseFinder::License, "BSD" do
  subject { described_class.find_by_name("BSD") }

  it "should match regardless of organization or copyright holder names or quotes" do
    license = <<-LICENSE
      Copyright (c) 2000, Widgets, Inc.
      All rights reserved.

      Redistribution and use in source and binary forms, with or without
      modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright
         notice, this list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright
         notice, this list of conditions and the following disclaimer in the
         documentation and/or other materials provided with the distribution.
      3. All advertising materials mentioning features or use of this software
         must display the following acknowledgement:
         This product includes software developed by <organization>.
      4. Neither the name of foo bar *%*%*%*% nor the
         names of its contributors may be used to endorse or promote products
         derived from this software without specific prior written permission.

      THIS SOFTWARE IS PROVIDED BY awesome *$*$* copyright name 'AS IS' AND ANY
      EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
      WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
      DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
      DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
      (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
      LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
      ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
      SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    LICENSE

    subject.should be_matches_text license
  end
end

describe LicenseFinder::License, "GPLv2" do
  it "should be findable" do
    described_class.find_by_name("GPLv2").should be
  end
end

describe LicenseFinder::License, "ISC" do
  it "should be findable" do
    described_class.find_by_name("ISC").should be
  end
end

describe LicenseFinder::License, "LGPL" do
  it "should be findable" do
    described_class.find_by_name("LGPL").should be
  end
end

describe LicenseFinder::License, "MIT" do
  subject { described_class.find_by_name "MIT" }

  describe "#matches_text?" do
    it "should return true if the text contains the MIT url" do
      subject.should be_matches_text "MIT License is awesome http://opensource.org/licenses/mit-license"

      subject.should be_matches_text "MIT Licence is awesome http://www.opensource.org/licenses/mit-license"

      subject.should_not be_matches_text "MIT Licence is awesome http://www!opensource!org/licenses/mit-license"
    end

    it "should return true if the text begins with 'The MIT License'" do
      subject.should be_matches_text "The MIT License"

      subject.should be_matches_text "The MIT Licence"

      subject.should_not be_matches_text "Something else\nThe MIT License"
    end

    it "should return true if the text contains 'is released under the MIT license'" do
      subject.should be_matches_text "is released under the MIT license"

      subject.should be_matches_text "is released under the MIT licence"
    end
  end
end

describe LicenseFinder::License, "NewBSD" do
  subject { described_class.find_by_name "NewBSD" }

  it "should match regardless of organization or copyright holder names" do
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

    subject.should be_matches_text license
  end

  it "should match with the alternate wording of third clause" do
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

    subject.should be_matches_text license
  end
end

describe LicenseFinder::License, "Python" do
  it "should be findable" do
    described_class.find_by_name("Python").should be
  end
end

describe LicenseFinder::License, "Ruby" do
  subject { described_class.find_by_name "Ruby" }

  describe "#matches?" do
    it "should return true when the Ruby license URL is present" do
      subject.should be_matches_text "This gem is available under the following license:\nhttp://www.ruby-lang.org/en/LICENSE.txt\nOkay?"
    end

    it "should return false when the Ruby License URL is not present" do
      subject.should_not be_matches_text "This gem is available under the following license:\nhttp://www.example.com\nOkay?"
    end

    it "should return false for pathological licenses" do
      subject.should_not be_matches_text "This gem is available under the following license:\nhttp://wwwzruby-langzorg/en/LICENSEztxt\nOkay?"
    end
  end
end

describe LicenseFinder::License, "SimplifiedBSD" do
  it "should be findable" do
    described_class.find_by_name("SimplifiedBSD").should be
  end
end
