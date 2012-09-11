require 'spec_helper'

describe LicenseFinder::License::Ruby do
  subject { LicenseFinder::License::Ruby.new("") }

  it_behaves_like "a license matcher"

  describe "#matches?" do
    it "should return true when the Ruby license URL is present" do
      subject.text = "This gem is available under the following license:\nhttp://www.ruby-lang.org/en/LICENSE.txt\nOkay?"
      should be_matches
    end

    it "should return false when the Ruby License URL is not present" do
      subject.text = "This gem is available under the following license:\nhttp://www.example.com\nOkay?"
      should_not be_matches
    end
  end
end
