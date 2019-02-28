require 'spec_helper'

 module LicenseFinder
  describe ComposerPackage do
    subject do
      described_class.new(
        "name" => "symfony/debug",
        "version" => "v3.0.7",
        "description" => "a description",
        "readme" => "a readme",
        "path" => "some/composer/package/path",
        "homepage" => "a homepage"
      )
    end

     its(:name) { should == "symfony/debug" }
    its(:version) { should == "v3.0.7" }
    its(:summary) { should eq "" }
    its(:description) { should == "a description" }
    its(:homepage) { should == "a homepage" }
    its(:install_path) { should eq "some/composer/package/path" }
    its(:package_manager) { should eq 'Composer' }

     describe '#license_names_from_spec' do
      let(:composer_module1) { {"license" => "MIT"} }
      let(:composer_module2) { {"licenses" => [{"type" => "BSD"}]} }
      let(:composer_module3) { {"license" => {"type" => "PSF"}} }
      let(:composer_module4) { {"licenses" => ["MIT"]} }
      let(:misdeclared_composer_module) { {"licenses" => {"type" => "MIT"}} }

       it 'finds the license for both license structures' do
        package = ComposerPackage.new(composer_module1)
        expect(package.license_names_from_spec).to eq ["MIT"]

         package = ComposerPackage.new(composer_module2)
        expect(package.license_names_from_spec).to eq ["BSD"]

         package = ComposerPackage.new(composer_module3)
        expect(package.license_names_from_spec).to eq ["PSF"]

         package = ComposerPackage.new(composer_module4)
        expect(package.license_names_from_spec).to eq ["MIT"]

         package = ComposerPackage.new(misdeclared_composer_module)
        expect(package.license_names_from_spec).to eq ["MIT"]
      end
    end
  end
end
