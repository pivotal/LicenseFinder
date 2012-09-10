require 'spec_helper'

describe LicenseFinder::License::Base do
  subject do
    Class.new(LicenseFinder::License::Base) do
      def self.name
        "LicenseFinder::License::Foo"
      end
    end.new("")
  end

  describe "#matches?" do
    context "when a license text template exists" do
      before do
        stub(File).exists?(/Foo\.txt/) { true }
        stub(File).read(/Foo\.txt/) { 'AWESOME "FOO" LICENSE' }
      end

      it "should return true if the body matches exactly" do
        subject.text = 'AWESOME "FOO" LICENSE'
        should be_matches
      end

      it "should return false if the body does not match at all" do
        subject.text = "hi"
        should_not be_matches
      end

      it "should return true if the body matches disregarding quote and new line differences" do
        subject.text = "AWESOME\n'FOO'\nLICENSE"
        should be_matches
      end
    end
  end
end

