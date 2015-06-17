require 'spec_helper'

module LicenseFinder
  describe GodepPackage do
    subject do
      described_class.new(
        {
          "ImportPath" => "github.com/cloudfoundry-incubator/candiedyaml",
          "Rev" => "5f3b3579b3dc360c8ad3f86fe9e59e58c5652d10",
          "Licenses" => [
            { "name" => "MIT" }
          ]
        }
      )
    end

    its(:name) { should == "candiedyaml" }
    its(:version) { should == "5f3b357" }
    its(:summary) { should == "" }
    its(:description) { should == "" }
    its(:homepage) { should == "" }
    its(:groups) { should == [] } # no way to get groups from Godep?
    its(:children) { should == [] } # no way to get children from Godep?
    its(:install_path) { should == "github.com/cloudfoundry-incubator/candiedyaml" }

    describe "#license_names_from_spec" do
      it "returns the license" do
        expect(subject.license_names_from_spec).to eq ["MIT"]
      end

      context "when there are no licenses" do
        subject { described_class.new({}) }

        it "is empty" do
          expect(subject.license_names_from_spec).to be_empty
        end
      end

      context "when there are multiple licenses" do
        subject do
          described_class.new(
            "Licenses" => [{ "name" => "1" }, { "name" => "2" }]
          )
        end

        it "returns multiple licenses" do
          expect(subject.license_names_from_spec).to eq ['1', '2']
        end
      end
    end
  end
end
