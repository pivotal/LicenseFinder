require 'spec_helper'

module LicenseFinder
  describe NPM do
    let(:npm) { NPM.new }
    it_behaves_like "a PackageManager"

    describe '.current_packages' do
      before { NPM.instance_variable_set(:@modules, nil) }

      it 'fetches data from npm' do
        json = <<-JSON
          {
            "dependencies": {
              "dependency.js": {
                "name": "depjs",
                "version": "1.3.3.7",
                "description": "description",
                "readme": "readme",
                "path": "/path/to/thing"
              },
              "dependency2.js": {
                "name": "dep2js",
                "version": "4.2",
                "description": "description2",
                "readme": "readme2",
                "path": "/path/to/thing2"
              }
            },
            "devDependencies": {
              "dependency3.js": {
                "name": "dep3js",
                "version": "4.2",
                "description": "description3",
                "readme": "readme3",
                "path": "/path/to/thing3"
              }
            },
            "notADependency": {
              "dependency6.js": {
                "name": "dep6js",
                "version": "4.2",
                "description": "description6",
                "readme": "readme6",
                "path": "/path/to/thing6"
              }
            }
          }
        JSON
        allow(npm).to receive(:capture).with(/npm/).and_return([json, true])

        current_packages = npm.current_packages

        expect(current_packages.map(&:name)).to eq(["depjs", "dep2js", "dep3js"])
        expect(current_packages.first).to be_a(Package)
        expect(current_packages.first.name).to eq("depjs")
      end

      it "does not support name version string" do
        json = <<-JSON
          {
            "devDependencies": {
              "foo": "4.2"
            }
          }
        JSON
        allow(npm).to receive(:capture).with(/npm/).and_return([json, true])

        current_packages = npm.current_packages

        expect(current_packages.map(&:name)).to eq([])
      end

      it "fails when command fails" do
        allow(npm).to receive(:capture).with(/npm/).and_return('Some error', false).once
        expect { npm.current_packages }.to raise_error(RuntimeError)
      end

      it "does not fail when command fails but produces output" do
        allow(npm).to receive(:capture).with(/npm/).and_return('{"foo":"bar"}', false).once
        npm.current_packages
      end
    end

    describe '.active?' do
      let(:package_path) { double(:package_file) }
      let(:npm) { NPM.new package_path: package_path }

      it 'is true with a package.json file' do
        allow(package_path).to receive_messages(:exist? => true)
        expect(npm).to be_active
      end

      it 'is false without a package.json file' do
        allow(package_path).to receive_messages(:exist? => false)
        expect(npm).to_not be_active
      end
    end
  end
end
