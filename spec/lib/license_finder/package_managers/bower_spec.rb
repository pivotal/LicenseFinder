require 'spec_helper'

module LicenseFinder
  describe Bower do
    subject { Bower.new(project_path: Pathname('/fake/path')) }

    it_behaves_like 'a PackageManager'

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
        allow(subject).to receive('`').with('cd /fake/path && bower list --json -l action').and_return(json)

        expect(subject.current_packages.map { |p| [p.name, p.install_path] }).to eq [
          %w(dependency-library /path/to/thing), %w(another-dependency /path/to/thing2)
        ]
      end
    end
  end
end
