require 'spec_helper'

module LicenseFinder
  describe CocoaPodsPackage do
    subject do
      described_class.new("Name", "1.0.0", license_text)
    end
    let(:license_text) { nil }

    it_behaves_like "it conforms to interface required by PackageSaver"

    its(:name) { should == "Name" }
    its(:version) { should == "1.0.0" }
    its(:summary) { should be_nil }
    its(:description) { should be_nil }
    its(:homepage) { should be_nil }
    its(:groups) { should == [] }
    its(:children) { should == [] }

    describe '#licenses' do
      context "when there's a license" do
        let(:license_text) { "LicenseText" }

        it "returns the name of the license if the license is found be text" do
          license = double(:license, name: "LicenseName")
          allow(License).to receive(:find_by_text).with(license_text).and_return(license)

          expect(subject.licenses.length).to eq 1
          expect(subject.licenses.first.name).to eq "LicenseName"
        end

        it "returns other if the license can't be found by text" do
          allow(License).to receive(:find_by_text).with(license_text).and_return(nil)

          expect(subject.licenses.length).to eq 1
          expect(subject.licenses.first.name).to eq "other"
        end
      end

      it "returns other when there's no license" do
        expect(subject.licenses.length).to eq 1
        expect(subject.licenses.first.name).to eq "other"
      end
    end
  end
end

