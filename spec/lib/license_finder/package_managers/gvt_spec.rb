require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Gvt do
    it_behaves_like "a PackageManager"
    describe "#current_packages" do
      subject { Gvt.new(project_path: Pathname('/app'), logger: double(:logger, active: nil)) }

      before do
        FakeFS.activate!
      end

      after do
        FakeFS.deactivate!
      end

      context "when the 'vendor' folder is nested in another folder" do
        include FakeFS::SpecHelpers
        it "returns the packages described by 'gvt list'" do
          FileUtils.mkdir_p '/app/anything/vendor'
          File.write('/app/anything/vendor/manifest',
                     '{
  "version": 0,
  "dependencies": [
    {
      "importpath": "github.com/aws/aws-sdk-go",
      "repository": "https://github.com/aws/aws-sdk-go",
      "vcs": "git",
      "revision": "ea4ed6c6aec305f9c990547f16141b3591493516",
      "branch": "master",
      "notests": true
    },
                {
      "importpath": "github.com/golang/protobuf/proto",
      "repository": "https://github.com/golang/protobuf",
      "vcs": "git",
      "revision": "8ee79997227bf9b34611aee7946ae64735e6fd93",
      "branch": "master",
      "path": "/proto",
      "notests": true
    }
  ]
}
')

          allow(subject).to receive(:capture).with('cd anything && gvt list -f "{{.Importpath}} {{.Revision}} {{.Repository}}"') do
            ["my-package-name 123abc example.com\npackage-name-2 456xyz anotherurl.com", true]
          end
          expect(subject.current_packages.length).to eq 2

          first = subject.current_packages.first
          expect(first.name).to eq 'my-package-name'
          expect(first.install_path).to eq Pathname('/app/anything/vendor/my-package-name')
          expect(first.version).to eq '123abc'
          expect(first.homepage).to eq 'example.com'

          last = subject.current_packages.last
          expect(last.name).to eq 'package-name-2'
          expect(last.install_path).to eq Pathname('/app/anything/vendor/package-name-2')
          expect(last.version).to eq '456xyz'
          expect(last.homepage).to eq 'anotherurl.com'
        end
      end

      context "when the 'vendor' folder is not nested in another folder" do
        include FakeFS::SpecHelpers
        it "returns the packages described by 'gvt list'" do
          FileUtils.mkdir_p '/app/vendor'
          File.write('/app/vendor/manifest',
                     '{
	"version": 0,
	"dependencies": [
		{
			"importpath": "github.com/aws/aws-sdk-go",
			"repository": "https://github.com/aws/aws-sdk-go",
			"vcs": "git",
			"revision": "ea4ed6c6aec305f9c990547f16141b3591493516",
			"branch": "master",
			"notests": true
		},
                {
			"importpath": "github.com/golang/protobuf/proto",
			"repository": "https://github.com/golang/protobuf",
			"vcs": "git",
			"revision": "8ee79997227bf9b34611aee7946ae64735e6fd93",
			"branch": "master",
			"path": "/proto",
			"notests": true
		}
	]
}
')

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
      end


      it "returns empty package list if 'gvt list' fails" do
        allow(subject).to receive(:capture).with(anything()) do
          ["my-package-name 123abc example.com\npackage-name-2 456xyz anotherurl.com", false]
        end
        expect(subject.current_packages).to eq []
      end
    end
  end
end
