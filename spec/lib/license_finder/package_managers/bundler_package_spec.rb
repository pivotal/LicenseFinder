require 'spec_helper'

module LicenseFinder
  describe BundlerPackage do
    subject { described_class.new(gemspec, nil) }

    it_behaves_like "a Package"

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
    its(:children) { should == ['foo'] }

    describe "#licenses" do
      def stub_license_files(license_files)
        allow(PossibleLicenseFiles).to receive(:find).and_return(license_files)
      end

      context "regardless of whether there are licenses in files" do
        before do
          stub_license_files [double(:file, license: License.find_by_name('Detected License'), path: "/")]
        end

        context 'if the gemspec provides two synonymous licenses' do
          before { gemspec.licenses = ['MIT', 'Expat'] }

          it 'returns the license only once' do
            expect(subject.licenses.length).to eq 1
            expect(subject.licenses.first.name).to eq "MIT"
          end
        end

        context 'if the gemspec provides many licenses' do
          before { gemspec.licenses = ['First Gemspec License', 'Second Gemspec License'] }

          it "returns 'multiple licenses' with the names of the licenses from the gemspec (but not those from detected files)" do
            expect(subject.licenses.length).to eq 2
            expect(subject.licenses.map(&:name)).to eq ["First Gemspec License", "Second Gemspec License"]
          end
        end
      end

      context "when there is nothing in the spec" do
        it "returns a license in a file if there is only one unique license detected" do
          stub_license_files([
            double(:first_file, license: License.find_by_name('MIT'), path: "/"),
            double(:second_file, license: License.find_by_name('Expat'), path: "/")
          ])

          expect(subject.licenses.length).to eq 1
          expect(subject.licenses.first.name).to eq "MIT"
        end

        it "returns 'unknown' if there are no licenses in files" do
          stub_license_files []

          expect(subject.licenses.length).to eq 1
          expect(subject.licenses.first.name).to eq "unknown"
        end

        it "returns 'multiple licenses' if there are many licenses in files" do
          stub_license_files([
            double(:first_file, license: License.find_by_name('First Detected License'), path: "/"),
            double(:second_file, license: License.find_by_name('Second Detected License'), path: "/")
          ])

          expect(subject.licenses.length).to eq 2
          expect(subject.licenses.map(&:name)).to eq ["First Detected License", "Second Detected License"]
        end
      end
    end

    describe "#groups" do
      subject { described_class.new(gemspec, bundler_dependency) }

      let(:bundler_dependency) { double(:dependency, groups: [1, 2, 3]) }

      it "returns bundler dependency's groups" do
        expect(subject.groups).to eq(bundler_dependency.groups)
      end
    end
  end
end
