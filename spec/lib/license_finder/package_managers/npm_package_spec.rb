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
        NpmPackage.new(node_module1).license.name.should eq("MIT")
        NpmPackage.new(node_module2).license.name.should eq("BSD")
        NpmPackage.new(node_module3).license.name.should eq("Python Software Foundation License")
        NpmPackage.new(node_module4).license.name.should eq("MIT")
      end

      context "regardless of whether there are licenses in files" do
        before do
          stub_license_files [double(:file, license: License.find_by_name('Detected License'))]
        end

        it "returns the license from the spec if there is only one unique license" do
          package = NpmPackage.new({ "licenses" => ["MIT", "Expat"], "path" => "/path/to/thing" })
          expect(package.license.name).to eq("MIT")
        end

        it "returns 'multiple licenses' if there's more than one license" do
          package = NpmPackage.new({ "licenses" => ["MIT", "BSD"], "path" => "/some/path" })
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

