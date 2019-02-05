# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe PossibleLicenseFile do
    context 'file parsing' do
      subject { described_class.new('root/nested/path') }

      context 'ignoring text' do
        before do
          allow(subject).to receive(:text).and_return('file text')
        end

        its(:text) { should == 'file text' } # this is a terrible test, considering the stubbing
        its(:path) { should == 'root/nested/path' }
      end
    end

    let(:logger) { double('Logger', info: nil) }
    subject { described_class.new('gem/license/path', logger: logger) }

    context 'with a known license' do
      before do
        allow(subject).to receive(:text).and_return('a known license')

        allow(License).to receive(:find_by_text).with('a known license').and_return(License.find_by_name('MIT'))
      end

      its(:license) { should == License.find_by_name('MIT') }
    end

    context 'with an unknown license' do
      before do
        allow(subject).to receive(:text).and_return('')
      end

      its(:license) { should be_nil }
    end

    context 'with dangling symlink' do
      let(:path) { Pathname(subject.path) }
      before do
        allow(Pathname).to receive(:new).with('gem/license/path').and_return(path)
        allow(path).to receive(:exist?).and_return(false)
      end

      it 'should log error msg' do
        expect(logger).to receive(:info).with('ERROR', 'gem/license/path does not exists', color: :red)
        subject.text
      end
    end
  end
end
