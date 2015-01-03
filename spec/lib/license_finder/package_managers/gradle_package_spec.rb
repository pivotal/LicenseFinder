require 'spec_helper'

module LicenseFinder
  describe GradlePackage do
    subject do
      described_class.new(
        "name" => "ch.qos.logback:logback-classic:1.1.1",
        "license" => [ { "name" => "MIT" } ]
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
      it "returns the license" do
        expect(subject.license_names_from_spec).to eq ["MIT"]
      end

      context "when there are no licenses" do
        subject { described_class.new("name" => "a:b:c") }

        it "is empty" do
          expect(subject.license_names_from_spec).to be_empty
        end
      end

      context "when there are no real licenses" do
        subject do
          described_class.new(
            "name" => "a:b:c",
            "license" => [ { "name" => "No license found"} ]
          )
        end

        it "is empty" do
          expect(subject.license_names_from_spec).to be_empty
        end
      end

      context "when there are multiple licenses" do
        subject do
          described_class.new(
            "name" => "a:b:c",
            "license" => [ { "name" => "1" }, { "name" => "2" } ]
          )
        end

        it "returns multiple licenses" do
          expect(subject.license_names_from_spec).to eq ['1', '2']
        end
      end
    end
  end
end

