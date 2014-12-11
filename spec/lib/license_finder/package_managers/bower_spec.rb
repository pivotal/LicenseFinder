require 'spec_helper'

module LicenseFinder
  describe Bower do
    let(:bower) { Bower.new }
    it_behaves_like "a PackageManager"

    describe '.current_packages' do
      it 'lists all the current packages' do
        json = <<-JSON
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
        JSON
        bower_stdout = double(:stdout, read: json)

        allow(Open3).to receive(:popen3).with('bower list --json').and_yield('input', bower_stdout, 'err', 'something')

        current_packages = bower.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end
    end

    describe '.active?' do
      let(:package_path) { double(:package_file) }
      let(:bower) { Bower.new package_path: package_path }

      it 'is true with a bower.json file' do
        allow(package_path).to receive_messages(:exist? => true)
        expect(bower).to be_active
      end

      it 'is false without a bower.json file' do
        allow(package_path).to receive_messages(:exist? => false)
        expect(bower).to_not be_active
      end
    end
  end
end
