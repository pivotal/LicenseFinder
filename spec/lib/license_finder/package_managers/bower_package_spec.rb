require 'spec_helper'

module LicenseFinder
  describe BowerPackage do
    subject do
      described_class.new(
        "canonicalDir" => "/path/to/thing",
        "pkgMeta" => {
          "name" => "dependency-library",
          "description" => "description",
          "version" => "1.3.3.7",
          "main" => "normalize.css",
          "readme" => "some readme stuff"
        }
      )
    end

    it_behaves_like "it conforms to interface required by PackageSaver"

    its(:name) { should == "dependency-library" }
    its(:version) { should == "1.3.3.7" }
    its(:summary) { should == "description" }
    its(:description) { should == "some readme stuff" }

    describe '#license' do
      def stub_license_files(license_files)
        PossibleLicenseFiles.stub(:find).with("/path/to/thing").and_return(license_files)
      end

      let(:package1) { { "pkgMeta" => {"license" => "MIT"} } }
      let(:package2) { { "pkgMeta" => {"licenses" => [{"type" => "BSD", "url" => "github.github/github"}]} } }
      let(:package3) { { "pkgMeta" => {"license" => {"type" => "PSF", "url" => "github.github/github"}} } }
      let(:package4) { { "pkgMeta" => {"licenses" => ["MIT"]} } }

      it 'finds the license for both license structures' do
        BowerPackage.new(package1).license.should eq("MIT")
        BowerPackage.new(package2).license.should eq("BSD")
        BowerPackage.new(package3).license.should eq("PSF")
        BowerPackage.new(package4).license.should eq("MIT")
      end

      it "returns a license in a file if detected" do
        stub_license_files [double(:file, license: 'Detected License')]

        subject.license.should == "Detected License"
      end

      it "returns 'other' otherwise" do
        stub_license_files []

        subject.license.should == "other"
      end
    end
  end
end

