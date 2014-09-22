require 'spec_helper'

module LicenseFinder
  describe NPM do
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
        allow(NPM).to receive(:capture).with(/npm/).and_return([json, true])

        current_packages = NPM.current_packages

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
        allow(NPM).to receive(:capture).with(/npm/).and_return([json, true])

        current_packages = NPM.current_packages

        expect(current_packages.map(&:name)).to eq([])
      end

      it "fails when command fails" do
        allow(NPM).to receive(:capture).with(/npm/).and_return('Some error', false).once
        expect { NPM.current_packages }.to raise_error(RuntimeError)
      end

      it "does not fail when command fails but produces output" do
        allow(NPM).to receive(:capture).with(/npm/).and_return('{"foo":"bar"}', false).once
        NPM.current_packages
      end
    end

    describe '.active?' do
      let(:package) { double(:package_file) }

      before do
        NPM.stub(package_path: package)
      end

      it 'is true with a package.json file' do
        package.stub(:exist? => true)
        expect(NPM).to be_active
      end

      it 'is false without a package.json file' do
        package.stub(:exist? => false)
        expect(NPM).to_not be_active
      end
    end
  end
end
