# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe CocoaPodsPackage do
    subject do
      described_class.new(name, '1.0.0', acknowledgement)
    end
    let(:acknowledgement) { { 'Title' => name, 'License' => spec_license, 'FooterText' => license_text }}
    let(:license_text) { nil }
    let(:spec_license) { nil }
    let(:name) { 'Name' }

    its(:name) { should == 'Name' }
    its(:version) { should == '1.0.0' }
    its(:summary) { should eq '' }
    its(:description) { should eq '' }
    its(:homepage) { should eq '' }
    its(:groups) { should == [] }
    its(:children) { should == [] }
    its(:package_manager) { should eq 'CocoaPods' }

    describe '#licenses' do
      context "when there's available license text in the acknowledgements" do
        let(:license_text) { 'LicenseText' }

        it 'returns the name of the license if the license is identified from the text' do
          license = double(:license, name: 'LicenseName')
          allow(License).to receive(:find_by_text).with(license_text).and_return(license)

          expect(subject.licenses.map(&:name)).to eq ['LicenseName']
        end

        it "returns unknown if the license can't be found by text" do
          allow(License).to receive(:find_by_text).with(license_text).and_return(nil)

          expect(subject.licenses.map(&:name)).to eq ['unknown']
        end
      end

      context "when there is a license name specified in the spec" do
        let(:spec_license) { 'LicenseName' }

        it 'returns the name of the license' do
          expect(subject.licenses.map(&:name)).to eq ['LicenseName']
        end
      end

      context "when there's both a license name and license text in the acknowledgements" do
        let(:license_text) { 'LicenseText' }
        let(:spec_license) { 'LicenseName' }

        it 'returns the name of the license from the spec' do
          expect(subject.licenses.map(&:name)).to eq ['LicenseName']
        end

        it 'does not look up the license by text' do
          expect(License).not_to receive(:find_by_text).with(license_text)
          subject.licenses
        end
      end

      it "returns unknown when there's no license" do
        expect(subject.licenses.map(&:name)).to eq ['unknown']
      end

      it 'respects license decisions' do
        subject.decide_on_license(License.find_by_name('A'))
        expect(subject.licenses.map(&:name)).to eq ['A']
      end
    end
  end
end
