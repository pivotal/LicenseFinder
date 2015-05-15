require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Nuget do

    it_behaves_like "a PackageManager"

    describe "#assemblies" do
      include FakeFS::SpecHelpers

      before do
        FileUtils.mkdir_p "app/packages"
        FileUtils.mkdir_p "app/Assembly1/"
        FileUtils.mkdir_p "app/Assembly1.Tests/"
        FileUtils.mkdir_p "app/Assembly2/"
        FileUtils.touch "app/Assembly1/packages.config"
        FileUtils.touch "app/Assembly1.Tests/packages.config"
        FileUtils.touch "app/Assembly2/packages.config"
      end

      it "finds dependencies all subdirectories containing a packages.config" do
        nuget = Nuget.new project_path: Pathname.new("app")
        expect(nuget.assemblies).to match_array ['Assembly1', 'Assembly1.Tests', 'Assembly2']
      end
    end
  end
end

