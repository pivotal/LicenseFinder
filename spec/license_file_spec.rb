require 'spec_helper'

describe LicenseFinder::LicenseFile do
  subject { LicenseFinder::LicenseFile.new('gem', 'gem/license/path') }

  before do
    stub(IO).read { "file text" }
  end

  its(:file_path) { should == 'license/path' }
  its(:file_name) { should == 'path' }
  its(:text) { should == 'file text' }

  describe "#to_hash" do
    it "does not include file text by default" do
      subject.to_hash.should == {'file_name' => 'license/path'}
    end
    it "includes file text if requested" do
      subject.include_license_text = true
      subject.to_hash.should == {'file_name' => 'license/path', 'text' => "file text"}
    end
  end
end
