require 'spec_helper'

describe LicenseFinder::ReadmeFile do
  subject { LicenseFinder::ReadmeFile.new('gem', 'gem/readme/path') }

  context "ignoring text" do
    before do
      stub(IO).read { "file text" }
    end

    describe "#to_hash" do
      it "includes file path" do
        subject.to_hash['file_name'].should == 'readme/path'
      end
      
      it "indicates whether readme mentions license" do
        subject.to_hash['mentions_license'].should == false
      end
    end
  end

  context "with readme that mentions license" do
    before do
      stub(IO).read { "\nMIT License"}
    end

    its(:mentions_license?) { should be_true }
  end

  context "with readme that does not mention license" do
    before do
      stub(IO).read { "usage" }
    end

    its(:mentions_license?) { should be_false }
  end
end
