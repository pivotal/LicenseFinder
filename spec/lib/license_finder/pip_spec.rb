require 'spec_helper'

module LicenseFinder
  describe Pip do
    describe '.current_dists' do
      it 'lists all the current dists' do
        allow(Pip).to receive(:`).with(/python/).and_return('[["jasmine", "1.3.1", "MIT"], ["jasmine-core", "1.3.1", "MIT"]]')

        current_dists = Pip.current_dists

        expect(current_dists.size).to eq(2)
        expect(current_dists.first).to be_a(Package)
      end

      it 'memoizes the current_dists' do
        allow(Pip).to receive(:`).with(/python/).and_return('[]').once

        Pip.current_dists
        Pip.current_dists
      end
    end

    describe '.has_requirements' do
      let(:requirements) { Pathname.new('requirements.txt').expand_path }

      context 'with a requirements file' do
        before :each do
          allow(File).to receive(:exists?).with(requirements).and_return(true)
        end

        it 'returns true' do
          expect(Pip.has_requirements?).to eq(true)
        end
      end

      context 'without a requirements file' do
        before :each do
          allow(File).to receive(:exists?).with(requirements).and_return(false)
        end

        it 'returns false' do
          expect(Pip.has_requirements?).to eq(false)
        end
      end
    end

    describe '.license_for' do
      let(:package) { PythonPackage.new(OpenStruct.new(name: 'jasmine', version: '1.3.1')) }

      before :each do
        stub_request(:get, "https://pypi.python.org/pypi/jasmine/1.3.1/json").
            to_return(:status => 200, :body => "{}", :headers => {})
      end

      it 'reaches out to PyPI with the package name and version' do
        Pip.license_for(package)

        WebMock.should have_requested(:get, "https://pypi.python.org/pypi/jasmine/1.3.1/json")
      end

      it 'returns the license from info => license preferentially' do
        data = { info: { license: "MIT", classifiers: [ 'License :: OSI Approved :: Apache 2.0 License' ] } }

        stub_request(:get, "https://pypi.python.org/pypi/jasmine/1.3.1/json").
            to_return(:status => 200, :body => JSON.generate(data), :headers => {})

        expect(Pip.license_for(package)).to eq('MIT')
      end

      it 'returns the first license from the classifiers if no info => license exists' do
        data = { info: { classifiers: [ 'License :: OSI Approved :: Apache 2.0 License' ] } }

        stub_request(:get, "https://pypi.python.org/pypi/jasmine/1.3.1/json").
            to_return(:status => 200, :body => JSON.generate(data), :headers => {})

        expect(Pip.license_for(package)).to eq('Apache 2.0 License')
      end

      it 'returns other if no license can be found' do
        data = {}

        stub_request(:get, "https://pypi.python.org/pypi/jasmine/1.3.1/json").
            to_return(:status => 200, :body => JSON.generate(data), :headers => {})

        expect(Pip.license_for(package)).to eq('other')
      end
    end
  end
end
