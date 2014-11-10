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

    it_behaves_like "a Package"

    its(:name) { should == "dependency-library" }
    its(:version) { should == "1.3.3.7" }
    its(:summary) { should == "description" }
    its(:description) { should == "some readme stuff" }
    its(:homepage) { should == "homepage" }
    its(:groups) { should == [] }
    its(:children) { should == [] }

    describe '#licenses' do
      def stub_license_files(license_files)
        allow(PossibleLicenseFiles).to receive(:find).with("/path/to/thing").and_return(license_files)
      end

      let(:package1) { { "pkgMeta" => {"license" => "MIT"}, "canonicalDir" => "/some/path" } }
      let(:package2) { { "pkgMeta" => {"licenses" => [{"type" => "BSD", "url" => "github.github/github"}]}, "canonicalDir" => "/some/path" } }
      let(:package3) { { "pkgMeta" => {"license" => {"type" => "PSF", "url" => "github.github/github"}}, "canonicalDir" => "/some/path" } }
      let(:package4) { { "pkgMeta" => {"licenses" => ["MIT"]}, "canonicalDir" => "/some/path" } }

      it 'finds the license for both license  structures' do
        package = BowerPackage.new(package1)
        expect(package.licenses.length).to eq 1
        expect(package.licenses.first.name).to eq("MIT")

        package = BowerPackage.new(package2)
        expect(package.licenses.length).to eq 1
        expect(package.licenses.first.name).to eq("BSD")

        package = BowerPackage.new(package3)
        expect(package.licenses.length).to eq 1
        expect(package.licenses.first.name).to eq("Python Software Foundation License")

        package = BowerPackage.new(package4)
        expect(package.licenses.length).to eq 1
        expect(package.licenses.first.name).to eq("MIT")
      end


      context "regardless of whether there are licenses in files" do
        before do
          stub_license_files [double(:file, license: License.find_by_name('Detected License'), path: "/")]
        end

        it "returns the license from the spec if there is only one unique license" do
          package = BowerPackage.new({ "pkgMeta" => {"licenses" => ["MIT", "Expat"]}, "canonicalDir" => "/path/to/thing" })
          expect(package.licenses.length).to eq 1
          expect(package.licenses.first.name).to eq("MIT")
        end

        it "returns 'multiple licenses' if there's more than one license" do
          package = BowerPackage.new({ "pkgMeta" => {"licenses" => ["MIT", "BSD"]}, "canonicalDir" => "/some/path" })
          expect(package.licenses.length).to eq 2
          expect(package.licenses.map(&:name)).to eq %w(MIT BSD)
        end
      end

      context "when there is nothing in the spec" do
        it "returns a license in a file if only one unique license detected" do
          stub_license_files([
            double(:first_file, license: License.find_by_name('MIT'), path: "/"),
            double(:second_file, license: License.find_by_name('Expat'), path: "/")
          ])

          expect(subject.licenses.length).to eq 1
          expect(subject.licenses.first.name).to eq "MIT"
        end

        it "returns 'other' if there are no licenses in files" do
          stub_license_files []

          expect(subject.licenses.length).to eq 1
          expect(subject.licenses.first.name).to eq "other"
        end

        it "returns 'other' if there are many licenses in files" do
          stub_license_files([
            double(:first_file, license: License.find_by_name('First Detected License'), path: "/"),
            double(:second_file, license: License.find_by_name('Second Detected License'), path: "/")
          ])

          expect(subject.licenses.length).to eq 2
          expect(subject.licenses.map(&:name)).to eq ["First Detected License", "Second Detected License"]
        end
      end
    end
  end
end

