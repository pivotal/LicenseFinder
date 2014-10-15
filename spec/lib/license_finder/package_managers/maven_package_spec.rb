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

    it_behaves_like "it conforms to interface required by PackageSaver"

    its(:name) { should == "hamcrest-core" }
    its(:version) { should == "4.11" }
    its(:description) { should == "" }

    describe "#licenses" do
      it "returns the license if found" do
        expect(subject.licenses.length).to eq 1
        expect(subject.licenses.first.name).to eq "Common Public License Version 1.0"
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

        it "returns 'multiple licenses'" do
          expect(subject.licenses.length).to eq 2
          expect(subject.licenses.map(&:name)).to eq ['Common Public License Version 1.0', 'Apache 2']
        end
      end

      context "when the license is not found" do
        subject do
          described_class.new(
            {
              "groupId" => "org.hamcrest",
              "artifactId" => "hamcrest-core",
              "licenses" => {}
             }
          )
        end

        it "returns 'other' otherwise" do
          expect(subject.licenses.length).to eq 1
          expect(subject.licenses.first.name).to eq "other"
        end
      end
    end
  end
end

