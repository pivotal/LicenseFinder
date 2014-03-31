require 'spec_helper'

module LicenseFinder
  describe NpmPackage do
    subject do
      described_class.new(
        "name" => "jasmine-node",
        "version" => "1.3.1",
        "description" => "a description",
        "readme" => "a readme",
        "path" => "some/node/package/path",
        "homepage" => "a homepage"
      )
    end

    it_behaves_like "it conforms to interface required by PackageSaver"

    its(:name) { should == "jasmine-node" }
    its(:version) { should == "1.3.1" }
    its(:summary) { should == "a description" }
    its(:description) { should == "a readme" }
    its(:homepage) { should == "a homepage" }
    its(:groups) { should == [] }
    its(:children) { should == [] }

    describe '#license' do
      def stub_license_files(license_files)
        PossibleLicenseFiles.stub(:find).with("some/node/package/path").and_return(license_files)
      end

      let(:node_module1) { {"license" => "MIT", "path" => "/some/path"} }
      let(:node_module2) { {"licenses" => [{"type" => "BSD"}], "path" => "/some/path"} }
      let(:node_module3) { {"license" => {"type" => "PSF"}, "path" => "/some/path"} }
      let(:node_module4) { {"licenses" => ["MIT"], "path" => "/some/path"} }

      it 'finds the license for both license structures' do
        NpmPackage.new(node_module1).license.should eq("MIT")
        NpmPackage.new(node_module2).license.should eq("BSD")
        NpmPackage.new(node_module3).license.should eq("PSF")
        NpmPackage.new(node_module4).license.should eq("MIT")
      end

      it "returns a license in a file if detected" do
        stub_license_files [double(:file, license: 'Detected License')]

        subject.license.should == "Detected License"
      end

      it "returns other if there's more than one license" do
        package = NpmPackage.new({ "licenses" => ["MIT", "BSD"], "path" => "/some/path" })
        expect(package.license).to eq("other")
      end

      it "returns other if the license from spec and license from files are different" do
        stub_license_files [double(:file, license: 'Detected License')]
        package = NpmPackage.new({ "licenses" => ["MIT"], "path" => "some/node/package/path" })

        expect(package.license).to eq("other")
      end

      it "returns 'other' otherwise" do
        stub_license_files []

        subject.license.should == "other"
      end
    end
  end
end

