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
        expect(nuget.assemblies.map(&:name)).to match_array ['Assembly1', 'Assembly1.Tests', 'Assembly2']
      end
    end

    describe "#current_packages" do
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

      before do
        assembly_1_packages = <<-ONE
        <?xml version="1.0" encoding="utf-8"?>
        <packages>
          <package id="GoToDependency" version="4.84.4790.14417" targetFramework="net45" />
          <package id="ObscureDependency" version="1.3.15" targetFramework="net45" />
          <package id="OtherObscureDependency" version="2.4.2" targetFramework="net45" />
        </packages>
        ONE

        assembly_1_tests_packages = <<-ONE
        <?xml version="1.0" encoding="utf-8"?>
        <packages>
          <package id="GoToDependency" version="4.84.4790.14417" targetFramework="net45" />
          <package id="TestFramework" version="5.0.1" targetFramework="net45" />
        </packages>
        ONE
        assembly_2_packages = <<-ONE
        <?xml version="1.0" encoding="utf-8"?>
        <packages>
          <package id="ObscureDependency" version="1.3.15" targetFramework="net45" />
          <package id="CoolNewDependency" version="2.4.2" targetFramework="net45" />
        </packages>
        ONE

        File.write("app/Assembly1/packages.config", assembly_1_packages)
        File.write("app/Assembly1.Tests/packages.config", assembly_1_tests_packages)
        File.write("app/Assembly2/packages.config", assembly_2_packages)
      end

      it "lists all the packages used in an assembly" do
        nuget = Nuget.new project_path: Pathname.new("app")
        deps = %w(GoToDependency
                  ObscureDependency
                  OtherObscureDependency
                  TestFramework
                  CoolNewDependency)
        expect(nuget.current_packages.map(&:name).uniq).to match_array(deps)
      end
    end
  end
end

