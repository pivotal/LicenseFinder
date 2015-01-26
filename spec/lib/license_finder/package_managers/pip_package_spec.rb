require 'spec_helper'

module LicenseFinder
  describe PipPackage do
    subject do
      make_package({
        "summary" => "summary",
        "description" => "description",
        "home_page" => "homepage"
      })
    end

    def make_package(pypi_def)
      described_class.new('jasmine', '1.3.1', "jasmine/install/path", pypi_def)
    end

    its(:name) { should == "jasmine" }
    its(:version) { should == "1.3.1" }
    its(:summary) { should == "summary" }
    its(:description) { should == "description" }
    its(:homepage) { should == "homepage" }
    its(:groups) { should == [] } # TODO: any way to extract install_requires and tests_require from `pip list` or `pip show`?
    its(:children) { should == [] } # TODO: use pipdeptree or something like it
    its(:install_path) { should eq "jasmine/install/path" }


    describe '#license_names_from_spec' do
      describe "with no pypi info" do
        it "is empty" do
          subject = make_package({})

          expect(subject.license_names_from_spec).to be_empty
        end
      end

      describe "with valid pypi license" do
        it "returns the license from 'license' preferentially" do
          data = { "license" => "MIT", "classifiers" => [ 'License :: OSI Approved :: Apache 2.0 License' ] }

          subject = make_package(data)

          expect(subject.license_names_from_spec).to eq ['MIT']
        end

        context "when there's no explicit license" do
          it "returns the license from the 'classifiers' if there is only one" do
            data = { "classifiers" => [ 'License :: OSI Approved :: Apache 2.0 License' ] }

            subject = make_package(data)

            expect(subject.license_names_from_spec).to eq ['Apache 2.0 License']
          end

          it "returns multiple licenses if there are many in 'classifiers'" do
            data = { "classifiers" => [ 'License :: OSI Approved :: Apache 2.0 License', 'License :: OSI Approved :: GPL' ] }

            subject = make_package(data)

            expect(subject.license_names_from_spec).to eq ['Apache 2.0 License', 'GPL']
          end
        end

        context "with UNKNOWN license" do
          it "returns the license from the classifier if it exists" do
            data = { "license" => "UNKNOWN", "classifiers" => [ 'License :: OSI Approved :: Apache 2.0 License' ] }

            subject = make_package(data)

            expect(subject.license_names_from_spec).to eq ['Apache 2.0 License']
          end
        end
      end
    end
  end
end
