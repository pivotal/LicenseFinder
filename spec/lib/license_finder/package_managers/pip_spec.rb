require 'spec_helper'

module LicenseFinder
  describe Pip do
    let(:pip) { Pip.new }
    it_behaves_like "a PackageManager"

    describe '.current_packages' do
      def stub_pip(stdout)
        allow(pip).to receive("`").with(/license_finder_pip.py/).and_return(stdout)
      end

      def stub_pypi(name, version, response)
        stub_request(:get, "https://pypi.python.org/pypi/#{name}/#{version}/json")
          .to_return(response)
      end

      it 'fetches data from pip' do
        stub_pip [
          {"name" => "jasmine", "version" => "1.3.1", "location" => "jasmine/path", "dependencies" => ["jasmine-core"]},
          {"name" => "jasmine-core", "version" => "1.3.1", "location" => "jasmine-core/path"}
        ].to_json
        stub_pypi("jasmine", "1.3.1", status: 200, body: '{}')
        stub_pypi("jasmine-core", "1.3.1", status: 200, body: '{}')

        expect(pip.current_packages.map { |p| [p.name, p.version, p.install_path.to_s, p.children] }).to eq [
          ["jasmine", "1.3.1", "jasmine/path/jasmine", ["jasmine-core"]],
          ["jasmine-core", "1.3.1", "jasmine-core/path/jasmine-core", []]
        ]
      end

      it "fetches data from pypi" do
        stub_pip [{"name" => "jasmine", "version" => "1.3.1", "location" => "jasmine/path"}].to_json
        stub_pypi("jasmine", "1.3.1", status: 200, body: JSON.generate(info: {summary: "A summary"}))

        expect(pip.current_packages.first.summary).to eq "A summary"
      end

      it "ignores pypi if it can't find useful info" do
        stub_pip [{"name" => "jasmine", "version" => "1.3.1", "location" => "jasmine/path"}].to_json
        stub_pypi("jasmine", "1.3.1", status: 404, body: '')

        expect(pip.current_packages.first.summary).to eq ""
      end
    end
  end
end
