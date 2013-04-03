require 'spec_helper'

module LicenseFinder
  describe LicenseFiles do
    def fixture_path(fixture)
      Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec', 'fixtures', fixture)).realpath.to_s
    end

    describe "#files" do
      it "is empty if there aren't any license files" do
        subject = described_class.new('/not/a/dir')
        subject.files.should == []
      end

      it "includes files with names like LICENSE, License or COPYING" do
        subject = described_class.new(fixture_path('license_names'))

        subject.files.map(&:file_name).should =~
        %w[COPYING.txt LICENSE Mit-License README.rdoc Licence.rdoc]
      end

      it "includes files deep in the hierarchy" do
        subject = described_class.new(fixture_path('nested_gem'))

        subject.files.map { |f| [f.file_name, f.file_path] }.should =~ [
          %w[LICENSE vendor/LICENSE]
        ]
      end

      it "includes both files nested inside LICENSE directory and top level files" do
        subject = described_class.new(fixture_path('license_directory'))
        found_license_files = subject.files

        found_license_files.map { |f| [f.file_name, f.file_path] }.should =~ [
          %w[BSD-2-Clause.txt LICENSE/BSD-2-Clause.txt],
          %w[GPL-2.0.txt LICENSE/GPL-2.0.txt],
          %w[MIT.txt LICENSE/MIT.txt],
          %w[RUBY.txt LICENSE/RUBY.txt],
          %w[COPYING COPYING],
          %w[LICENSE LICENSE/LICENSE]
        ]
      end

      it "handles non UTF8 encodings" do
        subject = described_class.new(fixture_path('utf8_gem'))
        expect { subject.files }.not_to raise_error
      end
    end
  end
end
