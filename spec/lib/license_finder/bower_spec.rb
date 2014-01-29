require 'spec_helper'

module LicenseFinder
  describe Bower do
    describe '.current_packages' do
      it 'lists all the current packages' do
        json = <<-resp
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
        resp
        allow(Bower).to receive(:`).with(/bower/).and_return(json)

        current_packages = Bower.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end
    end

    describe '.active?' do
      let(:package) { Pathname.new('bower.json').expand_path }

      context 'with a bower.json file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(true)
        end

        it 'returns true' do
          expect(Bower.active?).to eq(true)
        end
      end

      context 'without a bower.json file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(false)
        end

        it 'returns false' do
          expect(Bower.active?).to eq(false)
        end
      end
    end
  end
end
