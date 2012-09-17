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
      stub(details).license_files { [license_file] }
      details
    end

    let(:license_file) { LicenseFinder::PossibleLicenseFile.new('gem', 'gem/license/path') }

    it "returns the license from the gemspec if provided" do
      stub(gemspec).license { "Some License" }

      subject.determine_license.should == "Some License"
    end

    it "returns the matched license if detected" do
      stub(license_file).license { "Detected License" }

      subject.determine_license.should == "Detected License"
    end

    it "returns 'other' otherwise" do
      stub(license_file).license { nil }

      subject.determine_license.should == "other"
    end
  end

  describe "#license_files" do
    it "is empty if there aren't any license files" do
      subject.license_files.should == []
    end

    it "includes files with names like LICENSE, License or COPYING" do
      stub(gemspec).full_gem_path { fixture_path('license_names') }

      subject.license_files.map(&:file_name).should =~
        %w[COPYING.txt LICENSE Mit-License README.rdoc Licence.rdoc]
    end

    it "includes files deep in the hierarchy" do
      stub(gemspec).full_gem_path { fixture_path('nested_gem') }

      subject.license_files.map { |f| [f.file_name, f.file_path] }.should =~ [
        %w[LICENSE vendor/LICENSE]
      ]
    end

    it "includes both files nested inside LICENSE directory and top level files" do
      stub(gemspec).full_gem_path { fixture_path('license_directory') }
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
  end

  describe "#readme_files" do
    it "is empty if there aren't any readme files" do
      subject.readme_files.should == []
    end

    it "includes files with names like README, Readme or COPYING" do
      stub(gemspec).full_gem_path { fixture_path('readme') }

      subject.readme_files.map(&:file_name).should =~ [
        "Project ReadMe",
        "README",
        "Readme.markdown"
      ]
    end

    it "includes files deep in the hierarchy" do
      stub(gemspec).full_gem_path { fixture_path('nested_readme') }

      subject.readme_files.map { |f| [f.file_name, f.file_path] }.should =~ [
        %w[README vendor/README]
      ]
    end
  end

  describe '#to_dependency' do
    subject { LicenseFinder::BundledGem.new(gemspec).to_dependency }

    its(:name) { should == 'spec_name' }
    its(:version) { should == '2.1.3' }
    its(:summary) { should == 'summary' }
    its(:source) { should == 'bundle' }
    its(:description) { should == 'description' }
    its(:homepage) { should == 'homepage' }
    its(:children) { should == ['foo']}

    describe 'with a known license' do
      before do
        stub(gemspec).full_gem_path { fixture_path('mit_licensed_gem') }
        any_instance_of(LicenseFinder::PossibleLicenseFile, :license => 'Detected License')
      end

      its(:license) { should == 'Detected License' }
    end

    describe 'with an unknown license' do
      before do
        stub(gemspec).full_gem_path { fixture_path('other_licensed_gem') }
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
