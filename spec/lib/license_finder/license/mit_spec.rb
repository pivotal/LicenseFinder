require 'spec_helper'

describe LicenseFinder::License::MIT do
  subject { LicenseFinder::License::MIT.new("") }

  it_behaves_like "a license matcher"

  describe "#matches?" do
    it "should return true if the text contains the MIT url" do
      subject.text = "MIT License is awesome http://opensource.org/licenses/mit-license"
      should be_matches

      subject.text = "MIT Licence is awesome http://www.opensource.org/licenses/mit-license"
      should be_matches
    end

    it "should return true if the text contains 'The MIT License'" do
      subject.text = "The MIT License"
      should be_matches

      subject.text = "The MIT Licence"
      should be_matches
    end

    it "should return true if the text contains 'is released under the MIT license'" do
      subject.text = "is released under the MIT license"
      should be_matches

      subject.text = "is released under the MIT licence"
      should be_matches
    end
  end
end
