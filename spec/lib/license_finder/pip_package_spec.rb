require 'spec_helper'

module LicenseFinder
  describe PipPackage do
    subject { described_class.new('jasmine', '1.3.1', "jasmine/install/path") }

    it_behaves_like "it conforms to interface required by PackageSaver"

    def stub_pypi(data)
      stub_request(:get, "https://pypi.python.org/pypi/jasmine/1.3.1/json").
        to_return(:status => 200, :body => JSON.generate(data), :headers => {})
    end

    its(:name) { should == "jasmine" }
    its(:version) { should == "1.3.1" }

    describe "#summary" do
      it "delegates to pypi" do
        stub_pypi({ info: { summary: "A summary" } })
        expect(subject.summary).to eq("A summary")
      end

      it "falls back to nothing" do
        stub_pypi({})
        expect(subject.summary).to eq("")
      end
    end

    describe "#description" do
      it "delegates to pypi" do
        stub_pypi({ info: { description: "A description" } })
        expect(subject.description).to eq("A description")
      end

      it "falls back to nothing" do
        stub_pypi({})
        expect(subject.description).to eq("")
      end
    end

    describe '#license' do
      def stub_license_files(license_files)
        PossibleLicenseFiles.stub(:find).with("jasmine/install/path").and_return(license_files)
      end

      describe "with pypi license" do
        it 'returns the license from info => license preferentially' do
          data = { info: { license: "MIT", classifiers: [ 'License :: OSI Approved :: Apache 2.0 License' ] } }

          stub_pypi(data)

          expect(subject.license).to eq('MIT')
        end

        it 'returns the first license from the classifiers if no info => license exists' do
          data = { info: { classifiers: [ 'License :: OSI Approved :: Apache 2.0 License' ] } }

          stub_pypi(data)

          expect(subject.license).to eq('Apache 2.0 License')
        end
      end

      describe "without pypi license" do
        before do
          stub_pypi({})
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
