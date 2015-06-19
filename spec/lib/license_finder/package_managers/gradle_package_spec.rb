require 'spec_helper'

module LicenseFinder
  describe GradlePackage do
    subject do
      described_class.new(
        "name" => "ch.qos.logback:logback-classic:1.1.1",
        "license" => [ { "name" => "MIT" } ]
      )
    end

    its(:name) { should == "logback-classic" }
    its(:version) { should == "1.1.1" }
    its(:summary) { should == "" }
    its(:description) { should == "" }
    its(:homepage) { should == "" }
    its(:groups) { should == [] } # no way to get groups from gradle?
    its(:children) { should == [] } # no way to get children from gradle?
    its(:install_path) { should be_nil }

    describe '#eql?' do
      it 'returns true when the name version are equal' do
        package1 = GradlePackage.new('name' => 'unused:foo:1.0')
        package2 = GradlePackage.new('name' => 'unused:foo:1.0')

        expect(package1.eql?package2).to eq(true)
      end

      it 'returns false when the name and version are not equal' do
        package1 = GradlePackage.new('name' => 'unused:foo:1.0')
        package2 = GradlePackage.new('name' => 'unused:foo:2.0')
        package3 = GradlePackage.new('name' => 'unused:bar:1.0')

        expect(package1.eql?package2).not_to eq(true)
        expect(package1.eql?package3).not_to eq(true)
        expect(package2.eql?package3).not_to eq(true)
      end
    end

    describe '#hash' do
      it 'returns equal hash values the attributes are equal' do
        package1 = GradlePackage.new('name' => 'unused:foo:1.0')
        package2 = GradlePackage.new('name' => 'unused:foo:1.0')

        expect(package1.hash).to eq(package2.hash)
      end
    end

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

