require 'spec_helper'

module LicenseFinder
  describe PossibleLicenseFiles do
    def fixture_path(fixture)
      Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec', 'fixtures', fixture)).realpath.to_s
    end

    describe "#find" do
      it "is empty if there aren't any license files" do
        subject = described_class.new('/not/a/dir')
        expect(subject.find).to eq([])
      end

      it "includes files with names like LICENSE, License or COPYING" do
        subject = described_class.new(fixture_path('license_names'))

        expect(subject.find.map(&:file_path)).to match_array(
        %w[COPYING.txt LICENSE Mit-License README.rdoc Licence.rdoc]
        )
      end

      it "includes files deep in the hierarchy" do
        subject = described_class.new(fixture_path('nested_gem'))

        expect(subject.find.map(&:file_path)).to match_array(%w[vendor/LICENSE])
      end

      it "includes both files nested inside LICENSE directory and top level files" do
        subject = described_class.new(fixture_path('license_directory'))
        found_license_files = subject.find

        expect(found_license_files.map(&:file_path)).to match_array(%w[
          LICENSE/BSD-2-Clause.txt
          LICENSE/GPL-2.0.txt
          LICENSE/MIT.txt
          LICENSE/RUBY.txt
          COPYING
          LICENSE/LICENSE
        ])
      end

      it "handles non UTF8 encodings" do
        subject = described_class.new(fixture_path('utf8_gem'))
        expect { subject.find }.not_to raise_error
      end
    end
  end
end
