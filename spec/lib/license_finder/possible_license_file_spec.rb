require 'spec_helper'

describe LicenseFinder::PossibleLicenseFile do
  context "file parsing" do
    subject { LicenseFinder::PossibleLicenseFile.new('root', 'root/nested/path') }

    context "ignoring text" do
      before do
        subject.stub(:text).and_return('file text')
      end

      its(:file_path) { should == 'nested/path' }
      its(:file_name) { should == 'path' }
      its(:text) { should == 'file text' }
    end
  end

  subject { LicenseFinder::PossibleLicenseFile.new('gem', 'gem/license/path') }

  context "with a known license" do
    before do
      subject.stub(:text).and_return('a known license')

      LicenseFinder::License::MIT.stub(:new).with('a known license').and_return(double('MIT license', :matches? => true))
    end

    its(:license) { should == "MIT" }
  end

  context "with an unknown license" do
    before do
      subject.stub(:text).and_return('')
    end

    its(:license) { should be_nil }
  end
end
