require 'spec_helper'

module LicenseFinder
  describe NPM do
    describe '.current_modules' do
      before { NPM.instance_variable_set(:@modules, nil) }

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
        allow(NPM).to receive(:capture).with(/npm/).and_return([json, true])

        current_modules = NPM.current_modules

        expect(current_modules.size).to eq(2)
        expect(current_modules.first).to be_a(Package)
      end

      it 'memoizes the current_modules' do
        allow(NPM).to receive(:capture).with(/npm/).and_return(['{}', true]).once

        NPM.current_modules
        NPM.current_modules
      end

      it "fails when command fails" do
        allow(NPM).to receive(:capture).with(/npm/).and_return('Some error', false).once
        expect { NPM.current_modules }.to raise_error(RuntimeError)
      end
    end

    describe '.harvest_license' do
      let(:node_module1) { {"license" => "MIT"} }
      let(:node_module2) { {"licenses" => [{"type" => "BSD", "url" => "github.github/github"}]} }
      let(:node_module3) { {"license" => {"type" => "PSF", "url" => "github.github/github"}} }
      let(:node_module4) { {"licenses" => ["MIT"]} }

      it 'finds the license for both license structures' do
        NPM.harvest_license(node_module1).should eq("MIT")
        NPM.harvest_license(node_module2).should eq("BSD")
        NPM.harvest_license(node_module3).should eq("PSF")
        NPM.harvest_license(node_module4).should eq("MIT")
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
