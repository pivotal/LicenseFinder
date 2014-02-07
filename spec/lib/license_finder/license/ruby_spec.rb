require 'spec_helper'

describe LicenseFinder::License, "Ruby" do
  subject { LicenseFinder::License.find_by_name "Ruby" }

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
