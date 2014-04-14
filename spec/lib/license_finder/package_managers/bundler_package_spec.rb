require 'spec_helper'

module LicenseFinder
  describe BundlerPackage do
    subject { described_class.new(gemspec, nil) }

    it_behaves_like "it conforms to interface required by PackageSaver"

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

    its(:name) { should == 'spec_name' }
    its(:version) { should == '2.1.3' }
    its(:summary) { should == "summary" }
    its(:description) { should == "description" }
    its(:homepage) { should == "homepage" }
    its(:groups) { should == [] }
    its(:children) { should == [] }

    describe "#license" do
      def stub_license_files(license_files)
        PossibleLicenseFiles.stub(:find).and_return(license_files)
      end

      context "regardless of whether there are licenses in files" do
        before do
          stub_license_files [double(:file, license: License.find_by_name('Detected License'))]
        end

        it "returns the license from the gemspec if only one unique license provided" do
          gemspec.licenses = ['MIT', 'Expat']

          subject.license.name.should == "MIT"
        end

        it "returns 'other' if the gemspec provides many" do
          gemspec.licenses = ['First Gemspec License', 'Second Gemspec License']

          subject.license.name.should == "other"
        end
      end

      context "when there is nothing in the spec" do
        it "returns a license in a file if only one unique license detected" do
          stub_license_files([
            double(:first_file, license: License.find_by_name('MIT')),
            double(:second_file, license: License.find_by_name('Expat'))
          ])

          subject.license.name.should == "MIT"
        end

        it "returns 'other' if there are no licenses in files" do
          stub_license_files []

          subject.license.name.should == "other"
        end

        it "returns 'other' if there are many licenses in files" do
          stub_license_files([
            double(:first_file, license: License.find_by_name('First Detected License')),
            double(:second_file, license: License.find_by_name('Second Detected License'))
          ])

          subject.license.name.should == "other"
        end
      end
    end

    describe "#groups" do
      subject { described_class.new(gemspec, bundler_dependency) }

      let(:bundler_dependency) { double(:dependency, groups: [1, 2, 3]) }

      it "returns bundler dependency's groups" do
        subject.groups.should == bundler_dependency.groups
      end
    end
  end
end
