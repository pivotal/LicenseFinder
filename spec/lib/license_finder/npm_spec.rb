require 'spec_helper'

module LicenseFinder
  describe NPM do
    describe '.current_modules' do
      it 'lists all the current modules' do
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

        current_modules = NPM.current_modules

        expect(current_modules.size).to eq(2)
        expect(current_modules.first).to be_a(Package)
      end

      it 'memoizes the current_modules' do
        allow(NPM).to receive(:`).with(/npm/).and_return('{}').once

        NPM.current_modules
        NPM.current_modules
      end
    end

    describe '.has_package?' do
      let(:package) { Pathname.new('package.json').expand_path }

      context 'with a package.json file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(true)
        end

        it 'returns true' do
          expect(NPM.has_package?).to eq(true)
        end
      end

      context 'without a package file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(false)
        end

        it 'returns false' do
          expect(NPM.has_package?).to eq(false)
        end
      end
    end
  end
end
