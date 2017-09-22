require 'spec_helper'

module LicenseFinder
  describe Gvt do
    it_behaves_like "a PackageManager"
    describe "#current_packages" do
      subject { Gvt.new(project_path: Pathname('/app'), logger: double(:logger, active: nil)) }

      it "returns the packages described by 'gvt list'" do
        allow(subject).to receive(:capture).with('gvt list -f "{{.Importpath}} {{.Revision}} {{.Repository}}"') do
          ["my-package-name 123abc example.com\npackage-name-2 456xyz anotherurl.com", true]
        end
        expect(subject.current_packages.length).to eq 2

        first = subject.current_packages.first
        expect(first.name).to eq 'my-package-name'
        expect(first.install_path).to eq Pathname('/app/vendor/my-package-name')
        expect(first.version).to eq '123abc'
        expect(first.homepage).to eq 'example.com'

        last = subject.current_packages.last
        expect(last.name).to eq 'package-name-2'
        expect(last.install_path).to eq Pathname('/app/vendor/package-name-2')
        expect(last.version).to eq '456xyz'
        expect(last.homepage).to eq 'anotherurl.com'
      end

      it "returns empty package list if 'gvt list' fails" do
        allow(subject).to receive(:capture).with('gvt list -f "{{.Importpath}} {{.Revision}} {{.Repository}}"') do
          ["my-package-name 123abc example.com\npackage-name-2 456xyz anotherurl.com", false]
        end
        expect(subject.current_packages).to eq []
      end
    end
  end
end
