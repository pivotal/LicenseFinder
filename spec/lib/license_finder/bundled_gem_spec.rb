require 'spec_helper'

describe LicenseFinder::BundledGem do
  subject { LicenseFinder::BundledGem.new(gemspec) }

  let(:gemspec) do
    Gem::Specification.new do |s|
      s.name = 'spec_name'
      s.version = '2.1.3'
      s.summary = 'summary'
      s.description = 'description'
      s.homepage = 'homepage'

      s.add_dependency 'foo'
    end
  end

  def fixture_path(fixture)
    Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec', 'fixtures', fixture)).realpath.to_s
  end

  its(:name) { should == 'spec_name 2.1.3' }
  its(:dependency_name) { should == 'spec_name' }
  its(:dependency_version) { should == '2.1.3' }
  its(:install_path) { should == gemspec.full_gem_path }

  describe "#determine_license" do
    subject do
      details = LicenseFinder::BundledGem.new(gemspec)
      details.stub(:license_files).and_return([license_file])
      details
    end

    let(:license_file) { LicenseFinder::PossibleLicenseFile.new('gem', 'gem/license/path') }

    it "returns the license from the gemspec if provided" do
      gemspec.stub(:license).and_return('Some License')

      subject.determine_license.should == "Some License"
    end

    it "returns the matched license if detected" do
      license_file.stub(:license).and_return('Detected License')

      subject.determine_license.should == "Detected License"
    end

    it "returns 'other' otherwise" do
      license_file.stub(:license).and_return(nil)

      subject.determine_license.should == "other"
    end
  end

  describe "#license_files" do
    it "is empty if there aren't any license files" do
      subject.license_files.should == []
    end

    it "includes files with names like LICENSE, License or COPYING" do
      gemspec.stub(:full_gem_path).and_return(fixture_path('license_names'))

      subject.license_files.map(&:file_name).should =~
        %w[COPYING.txt LICENSE Mit-License README.rdoc Licence.rdoc]
    end

    it "includes files deep in the hierarchy" do
      gemspec.stub(:full_gem_path).and_return(fixture_path('nested_gem'))

      subject.license_files.map { |f| [f.file_name, f.file_path] }.should =~ [
        %w[LICENSE vendor/LICENSE]
      ]
    end

    it "includes both files nested inside LICENSE directory and top level files" do
      gemspec.stub(:full_gem_path).and_return(fixture_path('license_directory'))
      found_license_files = subject.license_files

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
      gemspec.stub(:full_gem_path).and_return(fixture_path('utf8_gem'))
      expect { subject.license_files }.not_to raise_error
    end
  end
end
