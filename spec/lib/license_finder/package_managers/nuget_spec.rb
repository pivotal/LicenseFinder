require 'spec_helper'
require 'fakefs/spec_helpers'
require 'zip'

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

      # cannot run on JRuby due to https://github.com/fakefs/fakefs/issues/303
      context 'when there is a .nupkg file', :skip => RUBY_PLATFORM =~ /java/ do
        before do
          obscure_dependency_nuspec = <<-HERE
          <?xml version="1.0"?>
          <package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
          <metadata>
            <id>ObscureDependency</id>
            <version>1.3.15</version>
            <licenseUrl>http://www.opensource.org/licenses/mit-license.php</licenseUrl>
          </metadata>
          </package>
          HERE
          File.write("app/packages/ObscureDependency.nuspec", obscure_dependency_nuspec)
          Dir.chdir 'app/packages' do
            Zip::File.open('ObscureDependency.1.3.15.nupkg', Zip::File::CREATE) do |zipfile|
              zipfile.add('ObscureDependency.nuspec', 'ObscureDependency.nuspec')
            end
          end
        end

        it "include the licenseUrl from the nuspec file" do
          nuget = Nuget.new project_path: Pathname.new("app")
          obscure_dep = nuget.current_packages.select { |dep| dep.name == 'ObscureDependency' }.first
          expect(obscure_dep.license_names_from_spec).to eq(['http://www.opensource.org/licenses/mit-license.php'])
        end
      end
    end
  end
end

