require 'spec_helper'
require 'fakefs/safe'

module LicenseFinder
  describe Godep do
    subject { Godep.new }

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

      it 'should return an array of packages based on the Godeps.json' do
        allow(IO).to receive(:read).with('Godeps/Godeps.json').and_return(content.to_s)
        packages = subject.current_packages
        expect(packages.map(&:name)).to include('foo', 'bar')
      end
    end

    describe '#godep_project?' do
      context 'when a Godeps/Godeps.json file exists' do
        it 'returns true' do
          FakeFS do
            FileUtils.mkdir('Godeps')
            File.open('Godeps/Godeps.json', 'w') {|f| f.write('Hello Godeps!!')}

            expect(subject.godep_project?).to be true
            FileUtils.rm_rf('Godeps')
          end
        end
      end

      context 'when a Godeps/Godeps.json file does not exist' do
        it 'returns false' do
          FakeFS do
            FileUtils.mkdir('Godeps')
            File.open('Godeps/main.go', 'w') {|f| f.write('Im a project, reallyzzzz')}

            expect(subject.godep_project?).to be false
            FileUtils.rm_rf('Godeps')
          end
        end
      end
    end
  end
end
