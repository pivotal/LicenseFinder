require 'spec_helper'

module LicenseFinder
  describe Pip do
    let!(:pip) { Pip.new }
    before { allow(Pip).to receive(:new) { pip } }

    describe '.current_packages' do
      def stub_pip(stdout)
        allow(pip).to receive("`").with(/license_finder_pip.py/).and_return(stdout)
      end

      def stub_pypi(name, version, response)
        stub_request(:get, "https://pypi.python.org/pypi/#{name}/#{version}/json").
          to_return(response)
      end

      it 'fetches data from pip' do
        stub_pip [
          {"name" => "jasmine", "version" => "1.3.1", "location" => "jasmine/path"},
          {"name" => "jasmine-core", "version" => "1.3.1", "location" => "jasmine-core/path"}
        ].to_json
        stub_pypi("jasmine", "1.3.1", status: 200, body: '{}')
        stub_pypi("jasmine-core", "1.3.1", status: 200, body: '{}')

        current_packages = pip.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end

      it "fetches data from pypi" do
        stub_pip [{"name" => "jasmine", "version" => "1.3.1", "location" => "jasmine/path"}].to_json
        stub_pypi("jasmine", "1.3.1", status: 200, body: JSON.generate(info: {summary: "A summary"}))

        expect(PipPackage).to receive(:new).with("jasmine", "1.3.1", "jasmine/path/jasmine", "summary" => "A summary")
        pip.current_packages
      end

      it "ignores pypi if it can't find useful info" do
        stub_pip [{"name" => "jasmine", "version" => "1.3.1", "location" => "jasmine/path"}].to_json
        stub_pypi("jasmine", "1.3.1", status: 404, body: '')

        expect(PipPackage).to receive(:new).with("jasmine", "1.3.1", "jasmine/path/jasmine", {})
        pip.current_packages
      end
    end

    describe '.active?' do
      let(:requirements) { double(:requirements_file) }

      before do
        allow(pip).to receive_messages(requirements_path: requirements)
      end

      it 'is true with a requirements.txt file' do
        allow(requirements).to receive_messages(:exist? => true)
        expect(pip).to be_active
      end

      it 'is false without a requirements.txt file' do
        allow(requirements).to receive_messages(:exist? => false)
        expect(pip).to_not be_active
      end
    end
  end
end
