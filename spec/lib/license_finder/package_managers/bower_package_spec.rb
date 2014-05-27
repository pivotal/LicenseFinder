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
        BowerPackage.new(package1).license.name.should eq("MIT")
        BowerPackage.new(package2).license.name.should eq("BSD")
        BowerPackage.new(package3).license.name.should eq("Python Software Foundation License")
        BowerPackage.new(package4).license.name.should eq("MIT")
      end


      context "regardless of whether there are licenses in files" do
        before do
          stub_license_files [double(:file, license: License.find_by_name('Detected License'))]
        end

        it "returns the license from the spec if there is only one unique license" do
          package = BowerPackage.new({ "pkgMeta" => {"licenses" => ["MIT", "Expat"]}, "canonicalDir" => "/path/to/thing" })
          expect(package.license.name).to eq("MIT")
        end

        it "returns 'multiple licenses' if there's more than one license" do
          package = BowerPackage.new({ "pkgMeta" => {"licenses" => ["MIT", "BSD"]}, "canonicalDir" => "/some/path" })
          expect(package.license.name).to eq("multiple licenses: MIT, BSD")
        end
      end

      context "when there is nothing in the spec" do
        it "returns a license in a file if only one unique license detected" do
          stub_license_files([
            double(:first_file, license: License.find_by_name('MIT')),
            double(:second_file, license: License.find_by_name('Expat'))
          ])

          subject.license.name.should == "MIT"
        end

        it "returns 'other' if there are no licenses in files" do
          stub_license_files []

          subject.license.name.should == "other"
        end

        it "returns 'other' if there are many licenses in files" do
          stub_license_files([
            double(:first_file, license: License.find_by_name('First Detected License')),
            double(:second_file, license: License.find_by_name('Second Detected License'))
          ])

          subject.license.name.should == "multiple licenses: First Detected License, Second Detected License"
        end
      end
    end
  end
end

