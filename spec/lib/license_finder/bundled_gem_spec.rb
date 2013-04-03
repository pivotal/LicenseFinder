require 'spec_helper'

module LicenseFinder
  describe BundledGem do
    subject { described_class.new(gemspec) }

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

    describe "#determine_license" do
      subject do
        details = BundledGem.new(gemspec)
        details.stub(:license_files).and_return([license_file])
        details
      end

      let(:license_file) { PossibleLicenseFile.new('gem', 'gem/license/path') }

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
      it "delegates to the license files helper" do
        LicenseFiles.should_receive(:new).with(gemspec.full_gem_path) { stub(files: [] )}
        subject.license_files
      end
    end
  end
end
