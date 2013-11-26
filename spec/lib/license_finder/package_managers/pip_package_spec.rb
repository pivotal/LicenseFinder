require 'spec_helper'

module LicenseFinder
  describe PipPackage do
    subject { make_package({}) }

    it_behaves_like "it conforms to interface required by PackageSaver"

    def make_package(pypi_def)
      described_class.new('jasmine', '1.3.1', "jasmine/install/path", pypi_def)
    end

    its(:name) { should == "jasmine" }
    its(:version) { should == "1.3.1" }

    describe "#summary" do
      it "delegates to pypi def" do
        subject = make_package("summary" => "A summary")
        expect(subject.summary).to eq("A summary")
      end

      it "falls back to nothing" do
        expect(subject.summary).to eq("")
      end
    end

    describe "#description" do
      it "delegates to pypi def" do
        subject = make_package("description" => "A description")
        expect(subject.description).to eq("A description")
      end

      it "falls back to nothing" do
        expect(subject.description).to eq("")
      end
    end

    describe '#license' do
      describe "with pypi license" do
        it "returns the license from 'license' preferentially" do
          data = { "license" => "MIT", "classifiers" => [ 'License :: OSI Approved :: Apache 2.0 License' ] }

          subject = make_package(data)

          expect(subject.license).to eq('MIT')
        end

        it "returns the first license from the 'classifiers' if no 'license' exists" do
          data = { "classifiers" => [ 'License :: OSI Approved :: Apache 2.0 License' ] }

          subject = make_package(data)

          expect(subject.license).to eq('Apache 2.0 License')
        end
      end

      describe "without pypi license" do
        def stub_license_files(license_files)
          PossibleLicenseFiles.stub(:find).with("jasmine/install/path").and_return(license_files)
        end

        it 'returns license from file' do
          stub_license_files [double(:license_file, license: 'License from file')]
          expect(subject.license).to eq('License from file')
        end

        it 'returns other if no license can be found' do
          stub_license_files []
          expect(subject.license).to eq('other')
        end
      end
    end
  end
end
