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
    its(:groups) { should == [] } # no way to get groups from bower?
    its(:children) { should == [] } # no way to get children from bower?
    its(:install_path) { should eq "/path/to/thing" }

    describe '#license_names_from_spec' do
      let(:package1) { { "pkgMeta" => {"license" => "MIT"} } }
      let(:package2) { { "pkgMeta" => {"licenses" => [{"type" => "BSD"}]} } }
      let(:package3) { { "pkgMeta" => {"license" => {"type" => "PSF"}} } }
      let(:package4) { { "pkgMeta" => {"licenses" => ["MIT"]} } }

      it 'finds the license for all license structures' do
        package = BowerPackage.new(package1)
        expect(package.license_names_from_spec.length).to eq 1
        expect(package.license_names_from_spec.first).to eq("MIT")

        package = BowerPackage.new(package2)
        expect(package.license_names_from_spec.length).to eq 1
        expect(package.license_names_from_spec.first).to eq("BSD")

        package = BowerPackage.new(package3)
        expect(package.license_names_from_spec.length).to eq 1
        expect(package.license_names_from_spec.first).to eq("PSF")

        package = BowerPackage.new(package4)
        expect(package.license_names_from_spec.length).to eq 1
        expect(package.license_names_from_spec.first).to eq("MIT")
      end
    end
  end
end

