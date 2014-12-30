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

    it_behaves_like "a Package"

    its(:name) { should == "logback-classic" }
    its(:version) { should == "1.1.1" }
    its(:summary) { should == "" }
    its(:description) { should == "" }
    its(:homepage) { should == "" }
    its(:groups) { should == [] } # no way to get groups from gradle?
    its(:children) { should == [] } # no way to get children from gradle?
    its(:install_path) { should be_nil }

    describe "#license_names_from_spec" do
      it "returns the license if found" do
        expect(subject.license_names_from_spec.length).to eq 1
        expect(subject.license_names_from_spec.first).to eq "Eclipse Public License - v 1.0"
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

        it "returns multiple licenses" do
          expect(subject.license_names_from_spec.length).to eq 2
          expect(subject.license_names_from_spec).to eq ['Eclipse Public License - v 1.0', 'GNU Lesser General Public License']
        end
      end
    end
  end
end

