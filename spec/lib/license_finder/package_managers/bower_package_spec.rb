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
          "readme" => "some readme stuff",
          "homepage" => "homepage"
        }
      )
    end

    it_behaves_like "it conforms to interface required by PackageSaver"

    its(:name) { should == "dependency-library" }
    its(:version) { should == "1.3.3.7" }
    its(:summary) { should == "description" }
    its(:description) { should == "some readme stuff" }
    its(:homepage) { should == "homepage" }
    its(:groups) { should == [] }
    its(:children) { should == [] }

    describe '#license' do
      def stub_license_files(license_files)
        PossibleLicenseFiles.stub(:find).with("/path/to/thing").and_return(license_files)
      end

      let(:package1) { { "pkgMeta" => {"license" => "MIT"}, "canonicalDir" => "/some/path" } }
      let(:package2) { { "pkgMeta" => {"licenses" => [{"type" => "BSD", "url" => "github.github/github"}]}, "canonicalDir" => "/some/path" } }
      let(:package3) { { "pkgMeta" => {"license" => {"type" => "PSF", "url" => "github.github/github"}}, "canonicalDir" => "/some/path" } }
      let(:package4) { { "pkgMeta" => {"licenses" => ["MIT"]}, "canonicalDir" => "/some/path" } }

      it 'finds the license for both license  structures' do
        BowerPackage.new(package1).license.should eq("MIT")
        BowerPackage.new(package2).license.should eq("BSD")
        BowerPackage.new(package3).license.should eq("PSF")
        BowerPackage.new(package4).license.should eq("MIT")
      end

      it "returns a license in a file if detected" do
        stub_license_files [double(:file, license: 'Detected License')]

        subject.license.should == "Detected License"
      end

      it "returns other if there's more than one license" do
        package = BowerPackage.new({ "pkgMeta" => {"licenses" => ["MIT", "BSD"]}, "canonicalDir" => "/some/path" })
        expect(package.license).to eq("other")
      end

      it "returns other if the license from spec and license from files are different" do
        stub_license_files [double(:file, license: 'Detected License')]
        package = BowerPackage.new({ "pkgMeta" => {"licenses" => ["MIT"]}, "canonicalDir" => "/path/to/thing" })

        expect(package.license).to eq("other")
      end

      it "returns 'other' otherwise" do
        stub_license_files []

        subject.license.should == "other"
      end
    end
  end
end

