require 'spec_helper'

module LicenseFinder
  describe Godep do
    subject { Godep.new(project_path: Pathname('/fake/path')) }

    it_behaves_like 'a PackageManager'

    describe '#current_packages' do
      let(:content) do
        '{
          "ImportPath": "github.com/pivotal/foo",
          "GoVersion": "go1.4.2",
          "Deps": [
            {
              "ImportPath": "github.com/pivotal/foo",
              "Rev": "61164e49940b423ba1f12ddbdf01632ac793e5e9"
            },
            {
              "ImportPath": "github.com/pivotal/bar",
              "Rev": "3245708abcdef234589450649872346783298736"
            }
          ]
        }'
      end

      before do
        allow(IO).to receive(:read).with(Pathname('/fake/path/Godeps/Godeps.json')).and_return(content.to_s)
      end

      it 'should return an array of required packages' do
        packages = subject.current_packages
        expect(packages.map(&:name)).to include('foo', 'bar')
      end

      context 'when dependencies are vendored' do
        before do
          allow(File).to receive(:exist?).with(Pathname('/fake/path/Godeps/_workspace')).and_return(true)
        end

        it 'should set the install_path to the vendored directory' do
          packages = subject.current_packages
          expect(packages[0].install_path).to eq('/fake/path/Godeps/_workspace/src/github.com/pivotal/foo')
          expect(packages[1].install_path).to eq('/fake/path/Godeps/_workspace/src/github.com/pivotal/bar')
        end
      end

      context 'when dependencies are not vendored' do
        before do
          ENV['GOPATH'] = '/fake/go/path'
        end

        after do
          ENV['GOPATH'] = nil
        end

        it 'should set the install_path to the GOPATH' do
          packages = subject.current_packages
          expect(packages[0].install_path).to eq('/fake/go/path/src/github.com/pivotal/foo')
          expect(packages[1].install_path).to eq('/fake/go/path/src/github.com/pivotal/bar')
        end
      end
    end
  end
end
