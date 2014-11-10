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

    it_behaves_like "a Package"

    its(:name) { should == "jasmine-node" }
    its(:version) { should == "1.3.1" }
    its(:summary) { should == "a description" }
    its(:description) { should == "a readme" }
    its(:homepage) { should == "a homepage" }
    its(:groups) { should == [] }
    its(:children) { should == [] }

    describe '#licenses' do
      def stub_license_files(license_files)
        allow(PossibleLicenseFiles).to receive(:find).with("some/node/package/path").and_return(license_files)
      end

      let(:node_module1) { {"license" => "MIT", "path" => "/some/path"} }
      let(:node_module2) { {"licenses" => [{"type" => "BSD"}], "path" => "/some/path"} }
      let(:node_module3) { {"license" => {"type" => "PSF"}, "path" => "/some/path"} }
      let(:node_module4) { {"licenses" => ["MIT"], "path" => "/some/path"} }
      let(:misdeclared_node_module) { {"licenses" => {"type" => "MIT"}} }

      it 'finds the license for both license structures' do
        package = NpmPackage.new(node_module1)
        expect(package.licenses.length).to eq 1
        expect(package.licenses.first.name).to eq("MIT")

        package = NpmPackage.new(node_module2)
        expect(package.licenses.length).to eq 1
        expect(package.licenses.first.name).to eq("BSD")

        package = NpmPackage.new(node_module3)
        expect(package.licenses.length).to eq 1
        expect(package.licenses.first.name).to eq("Python Software Foundation License")

        package = NpmPackage.new(node_module4)
        expect(package.licenses.length).to eq 1
        expect(package.licenses.first.name).to eq("MIT")

        package = NpmPackage.new(misdeclared_node_module)
        expect(package.licenses.length).to eq 1
        expect(package.licenses.first.name).to eq("MIT")
      end

      context "regardless of whether there are licenses in files" do
        before do
          stub_license_files [double(:file, license: License.find_by_name('Detected License'))]
        end

        it "returns the license from the spec if there is only one unique license" do
          package = NpmPackage.new({ "licenses" => ["MIT", "Expat"], "path" => "/path/to/thing" })
          expect(package.licenses.length).to eq 1
          expect(package.licenses.first.name).to eq("MIT")
        end

        it "returns 'multiple licenses' if there's more than one license" do
          package = NpmPackage.new({ "licenses" => ["MIT", "BSD"], "path" => "/some/path" })
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

