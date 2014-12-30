require 'spec_helper'

module LicenseFinder
  describe MavenPackage do
    subject do
      described_class.new(
        {
          "groupId" => "org.hamcrest",
          "artifactId" => "hamcrest-core",
          "version" => "4.11",
          "licenses" => [{
              "name" => "Common Public License Version 1.0",
              "url" => "http://www.opensource.org/licenses/cpl1.0.txt"
          }]
        }
      )
    end

    it_behaves_like "a Package"

    its(:name) { should == "hamcrest-core" }
    its(:version) { should == "4.11" }
    its(:summary) { should == "" }
    its(:description) { should == "" }
    its(:homepage) { should == "" }
    its(:groups) { should == [] } # no way to get groups from maven?
    its(:children) { should == [] } # no way to get children from maven?
    its(:install_path) { should be_nil }

    describe "#license_names_from_spec" do
      it "returns the license if found" do
        expect(subject.license_names_from_spec.length).to eq 1
        expect(subject.license_names_from_spec.first).to eq "Common Public License Version 1.0"
      end

      context "when there are multiple licenses" do
        subject do
          described_class.new(
            {
              "groupId" => "org.hamcrest",
              "artifactId" => "hamcrest-core",
              "licenses" => [{
                "name" => "Common Public License Version 1.0",
                "url" => "http://www.opensource.org/licenses/cpl1.0.txt"
              },
              {
                "name" => "Apache 2",
                "url" => "http://www.apache.org/licenses/LICENSE-2.0.txt"
              }]
            }
          )
        end

        it "returns multiple licenses" do
          expect(subject.license_names_from_spec.length).to eq 2
          expect(subject.license_names_from_spec).to eq ['Common Public License Version 1.0', 'Apache 2']
        end
      end
    end
  end
end

