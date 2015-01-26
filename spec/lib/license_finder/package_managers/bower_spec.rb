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
                  "name": "dependency-library"
                }
              },
              "another-dependency": {
                "canonicalDir": "/path/to/thing2",
                "pkgMeta": {
                  "name": "another-dependency"
                }
              }
            }
          }
        JSON
        allow(bower).to receive("`").with(/bower/).and_return(json)

        expect(bower.current_packages.map { |p| [p.name, p.install_path] }).to eq [
          ["dependency-library", "/path/to/thing"],
          ["another-dependency", "/path/to/thing2"]
        ]
      end
    end
  end
end
