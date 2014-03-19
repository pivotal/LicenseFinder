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
    its(:homepage) { should == nil }
    its(:groups) { should == [] }
    its(:children) { should == [] }

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

    describe "#homepage" do
      it "delegates to pypi def" do
        subject = make_package("home_page" => "A homepage")
        expect(subject.homepage).to eq("A homepage")
      end

      it "falls back to nothing" do
        expect(subject.homepage).to be_nil
      end
    end

    describe '#license' do
      describe "with valid pypi license" do
        it "returns the license from 'license' preferentially" do
          data = { "license" => "MIT", "classifiers" => [ 'License :: OSI Approved :: Apache 2.0 License' ] }

          subject = make_package(data)

          expect(subject.license.name).to eq('MIT')
        end

        context "when there's no explicit license" do
          it "returns the license from the 'classifiers' if there is only one" do
            data = { "classifiers" => [ 'License :: OSI Approved :: Apache 2.0 License' ] }

            subject = make_package(data)

            expect(subject.license.name).to eq('Apache 2.0 License')
          end

          it "returns 'other' if there is are multiple licenses in 'classifiers'" do
            data = { "classifiers" => [ 'License :: OSI Approved :: Apache 2.0 License', 'License :: OSI Approved :: GPL' ] }

            subject = make_package(data)

            expect(subject.license.name).to eq('other')
          end
        end


        context "with UNKNOWN license" do
          it "returns the license from the classifier if it exists" do
            data = { "license" => "UNKNOWN", "classifiers" => [ 'License :: OSI Approved :: Apache 2.0 License' ] }

            subject = make_package(data)

            expect(subject.license.name).to eq('Apache 2.0 License')
          end
        end
      end


      describe "without pypi license" do
        def stub_license_files(license_files)
          PossibleLicenseFiles.stub(:find).with("jasmine/install/path").and_return(license_files)
        end

        it 'returns license from file' do
          stub_license_files [double(:license_file, license: License.find_by_name('License from file'))]
          expect(subject.license.name).to eq('License from file')
        end

        it 'returns other if no license can be found' do
          stub_license_files []
          expect(subject.license.name).to eq('other')
        end
      end
    end
  end
end
