require 'spec_helper'

describe LicenseFinder::PossibleLicenseFile do
  context "file parsing" do
    subject { LicenseFinder::PossibleLicenseFile.new('root', 'root/nested/path') }

    context "ignoring text" do
      before do
        stub(IO).read { "file text" }
        stub(IO).binread { "file text" }
      end

      its(:file_path) { should == 'nested/path' }
      its(:file_name) { should == 'path' }
      its(:text) { should == 'file text' }
    end
  end

  subject { LicenseFinder::PossibleLicenseFile.new('gem', 'gem/license/path') }

  context "with a known license" do
    before do
      stub(IO).read { "a known license" }
      stub(IO).binread { "a known license" }

      stub(LicenseFinder::License::MIT).new("a known license").stub!.matches? { true }
    end

    its(:license) { should == "MIT" }
  end

  context "with an unknown license" do
    before do
      stub(IO).read { "" }
      stub(IO).binread { "" }

      any_instance_of(LicenseFinder::License::Base, :matches? => false)
    end

    its(:license) { should be_nil }
  end
end
