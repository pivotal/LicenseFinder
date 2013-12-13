require 'spec_helper'

module LicenseFinder
  describe Bower do
    describe '.current_packages' do
      it 'lists all the current packages' do
        json = <<-resp
{
  "dependencies": {
    "dependency-library": {
      "canonicalDir": "/path/to/thing",
      "pkgMeta": {
        "name": "dependency-library",
        "description": "description",
        "version": "1.3.3.7",
        "main": "normalize.css"
      }
    },
    "another-dependency": {
      "canonicalDir": "/path/to/thing2",
      "pkgMeta": {
        "name": "another-dependency",
        "description": "description2",
        "version": "4.2",
        "main": "denormalize.css"
      }
    }
  }
}
        resp
        allow(Bower).to receive(:`).with(/bower/).and_return(json)

        current_packages = Bower.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end

      it 'memoizes the current_packages' do
        allow(Bower).to receive(:`).with(/bower/).and_return('{}').once

        Bower.current_packages
        Bower.current_packages
      end
    end

    describe '.harvest_license' do
      let(:package1) { {"license" => "MIT"} }
      let(:package2) { {"licenses" => [{"type" => "BSD", "url" => "github.github/github"}]} }
      let(:package3) { {"license" => {"type" => "PSF", "url" => "github.github/github"}} }
      let(:package4) { {"licenses" => ["MIT"]} }

      it 'finds the license for both license structures' do
        Bower.harvest_license(package1).should eq("MIT")
        Bower.harvest_license(package2).should eq("BSD")
        Bower.harvest_license(package3).should eq("PSF")
        Bower.harvest_license(package4).should eq("MIT")
      end
    end

    describe '.has_package_file?' do
      let(:package) { Pathname.new('bower.json').expand_path }

      context 'with a bower.json file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(true)
        end

        it 'returns true' do
          expect(Bower.has_package_file?).to eq(true)
        end
      end

      context 'without a bower.json file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(false)
        end

        it 'returns false' do
          expect(Bower.has_package_file?).to eq(false)
        end
      end
    end
  end
end
