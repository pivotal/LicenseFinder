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
        allow(bower).to receive("`").with(/bower/).and_return(json)

        current_packages = bower.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end
    end
  end
end
