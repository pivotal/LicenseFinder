require 'spec_helper'
require 'fakefs/safe'


module LicenseFinder
  describe Godep do
    let(:godep) { Godep.new }
    it_behaves_like "a PackageManager"

    describe 'Detecting a Godep Managed Project' do
      context 'When a Godeps/Godeps.json file exists' do
        it 'returns true' do
          FakeFS do
            FileUtils.mkdir("Godeps")
            File.open("Godeps/Godeps.json", "w") {|f| f.write("Hello Godeps!!")}

            expect(godep.godep_project?).to be true
            FileUtils.rm_rf("Godeps")
          end
        end
      end

      context 'When a Godeps/Godeps.json file does not exist' do
        it 'returns false' do
          FakeFS do
            FileUtils.mkdir("Godeps")
            File.open("Godeps/main.go", "w") {|f| f.write("Im a project, reallyzzzz")}

            expect(godep.godep_project?).to be false
            FileUtils.rm_rf("Godeps")
          end
        end
      end
    end
  end
end
