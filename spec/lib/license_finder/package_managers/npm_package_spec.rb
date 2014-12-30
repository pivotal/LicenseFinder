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
        "homepage" => "a homepage",
        "dependencies" => {
          "coffee-script" => {
            "name" => "coffee-script",
          }
        }
      )
    end

    it_behaves_like "a Package"

    its(:name) { should == "jasmine-node" }
    its(:version) { should == "1.3.1" }
    its(:summary) { should eq "" }
    its(:description) { should == "a description" }
    its(:homepage) { should == "a homepage" }
    its(:groups) { should == [] } # no way to get groups from npm?
    its(:children) { should == ["coffee-script"] }
    its(:install_path) { should eq "some/node/package/path" }

    describe '#license_names_from_spec' do
      let(:node_module1) { {"license" => "MIT"} }
      let(:node_module2) { {"licenses" => [{"type" => "BSD"}]} }
      let(:node_module3) { {"license" => {"type" => "PSF"}} }
      let(:node_module4) { {"licenses" => ["MIT"]} }
      let(:misdeclared_node_module) { {"licenses" => {"type" => "MIT"}} }

      it 'finds the license for both license structures' do
        package = NpmPackage.new(node_module1)
        expect(package.license_names_from_spec.length).to eq 1
        expect(package.license_names_from_spec.first).to eq("MIT")

        package = NpmPackage.new(node_module2)
        expect(package.license_names_from_spec.length).to eq 1
        expect(package.license_names_from_spec.first).to eq("BSD")

        package = NpmPackage.new(node_module3)
        expect(package.license_names_from_spec.length).to eq 1
        expect(package.license_names_from_spec.first).to eq("PSF")

        package = NpmPackage.new(node_module4)
        expect(package.license_names_from_spec.length).to eq 1
        expect(package.license_names_from_spec.first).to eq("MIT")

        package = NpmPackage.new(misdeclared_node_module)
        expect(package.license_names_from_spec.length).to eq 1
        expect(package.license_names_from_spec.first).to eq("MIT")
      end
    end
  end
end
