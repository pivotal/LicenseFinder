require 'spec_helper'

describe LicenseFinder::GemSpecDetails do
  subject { LicenseFinder::GemSpecDetails.new(gemspec) }

  let(:gemspec) do
    Gem::Specification.new do |s|
      s.name = 'spec_name'
      s.version = '2.1.3'
      s.summary = 'summary'
      s.description = 'description'
    end
  end

  def fixture_path(fixture)
    File.realpath(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec', 'fixtures', fixture))
  end

  its(:name) { should == 'spec_name 2.1.3' }
  its(:dependency_name) { should == 'spec_name' }
  its(:dependency_version) { should == '2.1.3' }
  its(:install_path) { should == gemspec.full_gem_path }

  describe "#determine_license" do
    it "returns the license from the gemspec if provided" do
      stub(gemspec).license { "Some License" }
      LicenseFinder::GemSpecDetails.new(gemspec).determine_license.should == "Some License"
    end

    it "returns the matched license if detected" do
      mock_license_file = LicenseFinder::PossibleLicenseFile.new('gem', 'gem/license/path')
      stub(mock_license_file).license { LicenseFinder::License::Ruby.pretty_name }

      gemspec_details = LicenseFinder::GemSpecDetails.new(gemspec)
      stub(gemspec_details).license_files { [mock_license_file] }

      gemspec_details.determine_license.should == LicenseFinder::License::Ruby.pretty_name
    end

    it "returns 'other' otherwise" do
      mock_license_file = LicenseFinder::PossibleLicenseFile.new('gem', 'gem/license/path')
      stub(mock_license_file).license { nil }

      gemspec_details = LicenseFinder::GemSpecDetails.new(gemspec)
      stub(gemspec_details).license_files { [mock_license_file] }

      gemspec_details.determine_license.should == "other"
    end
  end

  describe "#license_files" do
    it "is empty if there aren't any license files" do
      LicenseFinder::GemSpecDetails.new(gemspec).license_files.should == []
    end

    it "includes files with names like LICENSE, License or COPYING" do
      stub(gemspec).full_gem_path { fixture_path('license_names') }
      LicenseFinder::GemSpecDetails.new(gemspec).license_files.map(&:file_name).should =~
        %w[COPYING.txt LICENSE Mit-License README.rdoc Licence.rdoc]
    end

    it "includes files deep in the hierarchy" do
      stub(gemspec).full_gem_path { fixture_path('nested_gem') }
      LicenseFinder::GemSpecDetails.new(gemspec).license_files.map { |f| [f.file_name, f.file_path] }.should =~
        [['LICENSE', 'vendor/LICENSE']]
    end

    it "includes both files nested inside LICENSE directory and top level files" do
      stub(gemspec).full_gem_path { fixture_path('license_directory') }
      found_license_files = LicenseFinder::GemSpecDetails.new(gemspec).license_files
      found_license_files.map(&:file_name).should =~
        %w[BSD-2-Clause.txt GPL-2.0.txt MIT.txt RUBY.txt COPYING LICENSE]
      found_license_files.map(&:file_path).should =~
        %w[LICENSE/BSD-2-Clause.txt LICENSE/GPL-2.0.txt LICENSE/MIT.txt  LICENSE/RUBY.txt COPYING LICENSE/LICENSE]
    end
  end

  describe "#readme_files" do
    it "is empty if there aren't any readme files" do
      LicenseFinder::GemSpecDetails.new(gemspec).readme_files.should == []
    end

    it "includes files with names like README, Readme or COPYING" do
      stub(gemspec).full_gem_path { fixture_path('readme') }
      LicenseFinder::GemSpecDetails.new(gemspec).readme_files.map(&:file_name).should =~
        %w[Project\ ReadMe README Readme.markdown]
    end

    it "includes files deep in the hierarchy" do
      stub(gemspec).full_gem_path { fixture_path('nested_readme') }
      LicenseFinder::GemSpecDetails.new(gemspec).readme_files.map { |f| [f.file_name, f.file_path] }.should =~
        [['README', 'vendor/README']]
    end
  end

  describe '#dependency' do
    subject { LicenseFinder::GemSpecDetails.new(gemspec).dependency }

    its(:name) { should == 'spec_name' }
    its(:version) { should == '2.1.3' }
    its(:summary) { should == 'summary' }
    its(:source) { should == 'bundle' }
    its(:description) { should == 'description' }

    describe 'with a known license' do
      before do
        stub(gemspec).full_gem_path { fixture_path('mit_licensed_gem') }
      end

      before do
        any_instance_of(LicenseFinder::PossibleLicenseFile, :license => 'Detected License')
      end

      its(:license) { should == 'Detected License' }
    end

    describe 'with an unknown license' do
      before do
        stub(gemspec).full_gem_path { fixture_path('other_licensed_gem') }
      end

      before do
        any_instance_of(LicenseFinder::PossibleLicenseFile, :license => nil)
      end

      its(:license) { should == 'other' }
    end

    describe 'with UTF8 file License' do
      before do
        stub(gemspec).full_gem_path { fixture_path('utf8_gem') }
      end

      it "handles non UTF8 encodings" do
        expect { subject }.not_to raise_error ArgumentError, "invalid byte sequence in UTF-8"
      end
    end
  end
end
