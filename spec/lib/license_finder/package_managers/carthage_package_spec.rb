# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe CarthagePackage do
    subject do
      described_class.new('Name', '1.0.0', license_text)
    end
    let(:license_text) { nil }

    its(:name) { should == 'Name' }
    its(:version) { should == '1.0.0' }
    its(:summary) { should eq '' }
    its(:description) { should eq '' }
    its(:homepage) { should eq '' }
    its(:groups) { should == [] }
    its(:children) { should == [] }
    its(:package_manager) { should eq 'Carthage' }

    describe '#licenses' do
      context "when there's a license" do
        let(:license_text) { 'LicenseText' }

        it 'returns the name of the license if the license is found be text' do
          license = double(:license, name: 'LicenseName')
          allow(License).to receive(:find_by_text).with(license_text).and_return(license)

          expect(subject.licenses.map(&:name)).to eq ['LicenseName']
        end

        it "returns unknown if the license can't be found by text" do
          allow(License).to receive(:find_by_text).with(license_text).and_return(nil)

          expect(subject.licenses.map(&:name)).to eq ['unknown']
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
