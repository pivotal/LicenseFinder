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
    its(:licenses_from_spec) { should == ["Common Public License Version 1.0"] }

    describe "#license" do
      it "returns the license if found" do
        subject.license.should == "Common Public License Version 1.0"
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

        it "returns 'other'" do
          subject.license.should == 'other'
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
          subject.license.should == "other"
        end
      end
    end
  end
end

