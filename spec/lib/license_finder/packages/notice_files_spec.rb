# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe NoticeFiles do
    describe '#initialize' do
      it 'handles a nil install path' do
        subject = described_class.new nil
        expect(subject.send(:install_path)).to eq(nil)
      end

      it 'handles a non-existant install path' do
        root_path = fixture_path('not/a/dir')
        subject = described_class.new root_path
        expect(subject.send(:install_path)).to eq(root_path)
      end

      it 'handles an existing install path' do
        root_path = fixture_path('notice_names')
        subject = described_class.new root_path
        expect(subject.send(:install_path)).to eq(root_path)
      end
    end

    describe '#find' do
      def files_in(fixture)
        root_path = fixture_path(fixture)
        subject = described_class.find(root_path.to_s)

        subject.map do |f|
          Pathname(f.path).relative_path_from(root_path).to_s
        end
      end

      it 'is empty if passed a nil install path' do
        subject = described_class.new nil
        expect(subject.find).to eq([])
      end

      it "is empty if there aren't any license files" do
        expect(files_in('not/a/dir')).to eq([])
      end

      it 'includes files named Notice' do
        expect(files_in('notice_names')).to match_array(['Notice'])
      end

      it 'includes files deep in the hierarchy' do
        expect(files_in('nested_gem')).to eq(['vendor/NOTICE'])
      end

      it 'handles non UTF8 encodings' do
        expect { files_in('non_utf8_gem') }.not_to raise_error
      end
    end
  end
end
