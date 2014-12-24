require 'spec_helper'

module LicenseFinder
  describe PossibleLicenseFile do
    context "file parsing" do
      subject { described_class.new('root', 'root/nested/path') }

      context "ignoring text" do
        before do
          allow(subject).to receive(:text).and_return('file text')
        end

        its(:text) { should == 'file text' } # this is a terrible test, considering the stubbing
        its(:path) { should == 'root/nested/path' }
      end
    end

    subject { described_class.new('gem', 'gem/license/path') }

    context "with a known license" do
      before do
        allow(subject).to receive(:text).and_return('a known license')

        allow(License).to receive(:find_by_text).with('a known license').and_return(License.find_by_name("MIT"))
      end

      its(:license) { should == License.find_by_name("MIT") }
    end

    context "with an unknown license" do
      before do
        allow(subject).to receive(:text).and_return('')
      end

      its(:license) { should be_nil }
    end
  end
end
