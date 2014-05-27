require 'spec_helper'

module LicenseFinder
  describe GradlePackage do
    subject do
      described_class.new(
        {
          "name" => "ch.qos.logback:logback-classic:1.1.1",
          "file" => ["logback-classic-1.1.1.jar"],
          "license" => [
            { "name" => "Eclipse Public License - v 1.0", "url"=>"http://www.eclipse.org/legal/epl-v10.html"}
          ]
        }
      )
    end

    it_behaves_like "it conforms to interface required by PackageSaver"

    its(:name) { should == "logback-classic" }
    its(:version) { should == "1.1.1" }
    its(:description) { should == "" }

    describe "#license" do
      it "returns the license if found" do
        subject.license.name.should == "Eclipse Public License - v 1.0"
      end

      context "when there are multiple licenses" do
        subject do
          described_class.new(
            {
              "name" => "ch.qos.logback:logback-classic:1.1.1",
              "file" => ["logback-classic-1.1.1.jar"],
              "license" => [
                { "name" => "Eclipse Public License - v 1.0", "url"=>"http://www.eclipse.org/legal/epl-v10.html"},
                { "name"=>"GNU Lesser General Public License", "url"=>"http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html"}
              ]
            }
          )
        end

        it "returns 'multiple licenses'" do
          subject.license.name.should == 'multiple licenses: Eclipse Public License - v 1.0, GNU Lesser General Public License'
        end
      end

      context "when the license is not found" do
        subject do
          described_class.new(
            {
              "name" => "ch.qos.logback:logback-classic:1.1.1",
              "file" => ["logback-classic-1.1.1.jar"],
              "license" => []
             }
          )
        end

        it "returns 'other' otherwise" do
          subject.license.name.should == "other"
        end
      end
    end
  end
end

