require 'spec_helper'

module LicenseFinder
  describe NPM do
    describe '.current_packages' do
      it 'fetches data from npm' do
        json = <<-resp
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
  }
}
        resp
        allow(NPM).to receive(:`).with(/npm/).and_return(json)

        current_packages = NPM.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
        expect(current_packages.first.name).to eq("depjs")
      end
    end

    describe '.active?' do
      let(:package) { Pathname.new('package.json').expand_path }

      context 'with a package.json file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(true)
        end

        it 'returns true' do
          expect(NPM.active?).to eq(true)
        end
      end

      context 'without a package file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(false)
        end

        it 'returns false' do
          expect(NPM.active?).to eq(false)
        end
      end
    end
  end
end
