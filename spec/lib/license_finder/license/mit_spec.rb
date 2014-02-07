require 'spec_helper'

describe LicenseFinder::License, "MIT" do
  subject { LicenseFinder::License.find_by_name "MIT" }
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
