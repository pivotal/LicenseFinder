require 'spec_helper'

module LicenseFinder
  describe Pip do
    describe '.current_packages' do
      def stub_pip(stdout)
        allow(Pip).to receive(:`).with(/python/).and_return(stdout)
      end

      def stub_pypi(name, version, response)
        stub_request(:get, "https://pypi.python.org/pypi/#{name}/#{version}/json").
          to_return(response)
      end

      it 'fetches data from pip' do
        stub_pip('[["jasmine", "1.3.1", "jasmine/path"], ["jasmine-core", "1.3.1", "jasmine-core/path"]]')
        stub_pypi("jasmine", "1.3.1", status: 200, body: '{}')
        stub_pypi("jasmine-core", "1.3.1", status: 200, body: '{}')

        current_packages = Pip.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end

      it "fetches data from pypi" do
        stub_pip('[["jasmine", "1.3.1", "jasmine/path"]]')
        stub_pypi("jasmine", "1.3.1", status: 200, body: JSON.generate(info: {summary: "A summary"}))

        expect(PipPackage).to receive(:new).with("jasmine", "1.3.1", "jasmine/path/jasmine", "summary" => "A summary")
        Pip.current_packages
      end

      it "ignores pypi if it can't find useful info" do
        stub_pip('[["jasmine", "1.3.1", "jasmine/path"]]')
        stub_pypi("jasmine", "1.3.1", status: 404, body: '')

        expect(PipPackage).to receive(:new).with("jasmine", "1.3.1", "jasmine/path/jasmine", {})
        Pip.current_packages
      end
    end

    describe '.active?' do
      let(:requirements) { Pathname.new('requirements.txt').expand_path }

      context 'with a requirements file' do
        before :each do
          allow(File).to receive(:exists?).with(requirements).and_return(true)
        end

        it 'returns true' do
          expect(Pip.active?).to eq(true)
        end
      end

      context 'without a requirements file' do
        before :each do
          allow(File).to receive(:exists?).with(requirements).and_return(false)
        end

        it 'returns false' do
          expect(Pip.active?).to eq(false)
        end
      end
    end
  end
end
