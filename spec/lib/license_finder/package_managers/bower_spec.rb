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
    end

    describe '.active?' do
      let(:package) { double(:package_file) }

      before do
        allow(Bower).to receive_messages(package_path: package)
      end

      it 'is true with a bower.json file' do
        allow(package).to receive_messages(:exist? => true)
        expect(Bower).to be_active
      end

      it 'is false without a bower.json file' do
        allow(package).to receive_messages(:exist? => false)
        expect(Bower).to_not be_active
      end
    end
  end
end
