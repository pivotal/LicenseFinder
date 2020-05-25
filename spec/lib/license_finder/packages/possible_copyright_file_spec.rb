# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe PossibleCopyrightFile do
    context 'file parsing' do
      subject { described_class.new(fixture_path('copyrights/COPYING.txt')) }

      its(:text) { should == "The MIT License\n\nCopyright 2020 by Sven\n" }
      its(:path) { should == fixture_path('copyrights/COPYING.txt').to_s }
    end

    let(:logger) { double('Logger', info: nil) }
    subject { described_class.new('gem/license/path', logger: logger) }

    context 'with a known copyright' do
      before do
        allow(subject).to receive(:text).and_return('Copyright 2020 by Sven')
      end

      its(:copyright) { should == Copyright.find_by_text('Copyright 2020 by Sven') }
    end

    context 'with an unknown copyright' do
      before do
        allow(subject).to receive(:text).and_return('')
      end

      its(:copyright) { should be_nil }
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
