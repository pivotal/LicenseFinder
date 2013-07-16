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

    describe "#license" do
      subject do
        details = BundledGem.new(gemspec)
        details.stub(:license_files).and_return([license_file])
        details
      end

      let(:license_file) { PossibleLicenseFile.new('gem', 'gem/license/path') }

      it "returns the license from the gemspec if provided" do
        gemspec.stub(:license).and_return('Some License')

        subject.license.should == "Some License"
      end

      it "returns the matched license if detected" do
        license_file.stub(:license).and_return('Detected License')

        subject.license.should == "Detected License"
      end

      it "returns 'other' otherwise" do
        license_file.stub(:license).and_return(nil)

        subject.license.should == "other"
      end
    end

    describe "#license_files" do
      it "delegates to the license files helper" do
        PossibleLicenseFiles.should_receive(:new).with(gemspec.full_gem_path) { double(find: [] )}
        subject.license_files
      end
    end

    describe "#groups" do
      context "bundler_dependency is present" do
        subject { described_class.new(gemspec, bundler_dependency) }

        let(:bundler_dependency) { double(:dependency, groups: [1, 2, 3]) }

        it "returns bundler dependency's groups" do
          subject.groups.should == bundler_dependency.groups
        end
      end

      context "bundler_dependency is nil" do
        it "returns empty array" do
          subject.groups.should == []
        end
      end
    end
  end
end
