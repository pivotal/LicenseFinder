# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'
require 'zip'

module LicenseFinder
  describe Nuget do
    it_behaves_like 'a PackageManager'

    describe '#assemblies' do
      include FakeFS::SpecHelpers

      before do
        FileUtils.mkdir_p 'app/packages'
        FileUtils.mkdir_p 'app/Assembly1/'
        FileUtils.mkdir_p 'app/Assembly1.Tests/'
        FileUtils.mkdir_p 'app/Assembly2/'
        FileUtils.touch 'app/Assembly1/packages.config'
        FileUtils.touch 'app/Assembly1.Tests/packages.config'
        FileUtils.touch 'app/Assembly2/packages.config'
      end

      it 'finds dependencies all subdirectories containing a packages.config' do
        nuget = Nuget.new project_path: Pathname.new('app')
        expect(nuget.assemblies.map(&:name)).to match_array ['Assembly1', 'Assembly1.Tests', 'Assembly2']
      end

      context 'when packages.config is in .nuget directory' do
        before do
          FileUtils.mkdir_p 'app/.nuget'
          FileUtils.touch 'app/.nuget/packages.config'
        end

        it 'finds dependencies all subdirectories containing a packages.config' do
          nuget = Nuget.new project_path: Pathname.new('app')
          expect(nuget.assemblies.map(&:name)).to include('.nuget')
        end
      end
    end

    describe '#detected_package_path' do
      include FakeFS::SpecHelpers

      context 'when .nupkg files exist, but are not in .nuget directory' do
        before do
          FileUtils.mkdir_p 'app/submodule/vendor'
          FileUtils.touch 'app/submodule/vendor/package.nupkg'
          FileUtils.mkdir_p 'app/vendor'
          FileUtils.touch 'app/vendor/package.nupkg'
        end

        it 'returns vendored directory' do
          nuget = Nuget.new project_path: Pathname.new('app')
          expect(nuget.detected_package_path).to eq Pathname('/app/vendor')
        end
      end

      context 'when .nuget exists' do
        before do
          FileUtils.mkdir_p 'app/.nuget'
        end

        it 'returns the packages.config file path' do
          nuget = Nuget.new project_path: Pathname.new('app')
          expect(nuget.detected_package_path).to eq Pathname('app/.nuget')
        end
      end

      context 'when vendor/*.nupkg and .nuget/ are not present but packages.config file exists' do
        before do
          FileUtils.mkdir_p 'app'
          FileUtils.touch 'app/packages.config'
        end

        it 'returns the packages.config file' do
          nuget = Nuget.new project_path: Pathname.new('app')
          expect(nuget.detected_package_path).to eq Pathname('app/packages.config')
        end
      end

      context 'when *.sln file exists' do
        before do
          FileUtils.mkdir_p 'app'
          FileUtils.touch 'app/MyApp.sln'
        end

        it 'returns the solution file' do
          nuget = Nuget.new project_path: Pathname.new('app')
          expect(nuget.detected_package_path).to eq Pathname('/app/MyApp.sln')
        end
      end
    end

    describe '#current_packages' do
      include FakeFS::SpecHelpers
      before do
        FileUtils.mkdir_p 'app/packages'
        FileUtils.mkdir_p 'app/Assembly1/'
        FileUtils.mkdir_p 'app/Assembly1.Tests/'
        FileUtils.mkdir_p 'app/Assembly2/'
        FileUtils.touch 'app/Assembly1/packages.config'
        FileUtils.touch 'app/Assembly1.Tests/packages.config'
        FileUtils.touch 'app/Assembly2/packages.config'
      end

      let(:assembly_1_packages) do
        <<-ONE
        <?xml version="1.0" encoding="utf-8"?>
        <packages>
          <package id="GoToDependency" version="4.84.4790.14417" targetFramework="net45" />
          <package id="ObscureDependency" version="1.3.15" targetFramework="net45" />
          <package id="OtherObscureDependency" version="2.4.2" targetFramework="net45" />
        </packages>
        ONE
      end

      let(:assembly_1_tests_packages) do
        <<-ONE
        <?xml version="1.0" encoding="utf-8"?>
        <packages>
          <package id="GoToDependency" version="4.84.4790.14417" targetFramework="net45" />
          <package id="TestFramework" version="5.0.1" targetFramework="net45" />
        </packages>
        ONE
      end

      let(:assembly_2_packages) do
        <<-ONE
        <?xml version="1.0" encoding="utf-8"?>
        <packages>
          <package id="ObscureDependency" version="1.3.15" targetFramework="net45" />
          <package id="CoolNewDependency" version="2.4.2" targetFramework="net45" />
        </packages>
        ONE
      end

      before do
        File.write('app/Assembly1/packages.config', assembly_1_packages)
        File.write('app/Assembly1.Tests/packages.config', assembly_1_tests_packages)
        File.write('app/Assembly2/packages.config', assembly_2_packages)
      end

      it 'lists all the packages used in an assembly' do
        nuget = Nuget.new project_path: Pathname.new('app')
        deps = %w[GoToDependency
                  ObscureDependency
                  OtherObscureDependency
                  TestFramework
                  CoolNewDependency]
        expect(nuget.current_packages.map(&:name).uniq).to match_array(deps)
      end

      # cannot run on JRuby due to https://github.com/fakefs/fakefs/issues/303
      context 'when there is a .nupkg file', skip: LicenseFinder.broken_fakefs? do
        before do
          obscure_dependency_nuspec = <<-XML
            <?xml version="1.0"?>
            <package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
              <metadata>
                <id>ObscureDependency</id>
                <version>1.3.15</version>
                <licenseUrl>http://www.opensource.org/licenses/mit-license.php</licenseUrl>
              </metadata>
            </package>
          XML
          File.write('app/packages/ObscureDependency.nuspec', obscure_dependency_nuspec)
          Dir.chdir 'app/packages' do
            Zip::File.open('ObscureDependency.1.3.15.nupkg', Zip::File::CREATE) do |zipfile|
              zipfile.add('ObscureDependency.nuspec', 'ObscureDependency.nuspec')
            end
          end
        end

        it 'include the licenseUrl from the nuspec file' do
          nuget = Nuget.new project_path: Pathname.new('app')
          obscure_dep = nuget.current_packages.select { |dep| dep.name == 'ObscureDependency' }.first
          expect(obscure_dep.license_names_from_spec).to eq(['http://www.opensource.org/licenses/mit-license.php'])
        end
      end
    end

    shared_examples 'a NuGet package manager' do
      describe '.prepare_command' do
        it 'returns the correct prepare method' do
          expect(described_class.prepare_command).to eq("#{nuget_cmd} restore")
        end
      end

      describe '.package_management_command' do
        it 'returns the correct package management command' do
          expect(described_class.package_management_command).to eq(nuget_cmd)
        end
      end

      describe '.installed?' do
        it 'returns true if nuget installed' do
          expect(SharedHelpers::Cmd).to receive(:run).with(nuget_check).and_return([nuget_location, '', cmd_success])
          expect(Nuget.installed?).to eq(true)
        end

        it 'returns false if no nuget' do
          expect(SharedHelpers::Cmd).to receive(:run).with(nuget_check).and_return(['', '', cmd_failure])
          expect(Nuget.installed?).to eq(false)
        end
      end

      describe '.prepare' do
        nuget_restore_output = <<-CMDOUTPUT
Restoring NuGet package ObscureDependency.1.3.15.
Restoring NuGet package CoolNewDependency.2.4.2.
        CMDOUTPUT

        include FakeFS::SpecHelpers
        before do
          FileUtils.mkdir_p 'app'
          FileUtils.touch 'app/MyApp.sln'
        end

        it 'should call nuget restore' do
          nuget = Nuget.new project_path: Pathname.new('app')
          expect(SharedHelpers::Cmd).to receive(:run).with("#{nuget_cmd} restore")
                                                     .and_return([nuget_restore_output, '', cmd_success])
          nuget.prepare
        end
      end

      describe '.nuspec_license_urls' do
        let(:thing1_spec) do
          <<-XML
          <?xml version="1.0" encoding="utf-8"?>
          <package xmlns="http://schemas.microsoft.com/packaging/2013/05/nuspec.xsd">
            <metadata minClientVersion="3.6">
              <licenseUrl>https://example.com</licenseUrl>
            </metadata>
          </package>
          XML
        end

        it 'should find defined license URL' do
          expect(Nuget.nuspec_license_urls(thing1_spec)).to eq(['https://example.com'])
        end
      end
    end

    context 'linux' do
      before(:each) do
        allow(LicenseFinder::Platform).to receive(:windows?).and_return(false)
      end

      let(:nuget_cmd) { 'mono /usr/local/bin/nuget.exe' }
      let(:nuget_check) { 'which mono && ls /usr/local/bin/nuget.exe' }
      let(:nuget_location) { "/usr/local/mono\n/usr/local/bin/nuget.exe" }

      it_behaves_like 'a NuGet package manager'
    end

    context 'windows' do
      before(:each) do
        allow(LicenseFinder::Platform).to receive(:windows?).and_return(true)
      end

      let(:nuget_cmd) { 'nuget' }
      let(:nuget_check) { 'where nuget' }
      let(:nuget_location) { 'C:\\ProgramData\\chocolatey\\bin\\NuGet.exe' }

      it_behaves_like 'a NuGet package manager'
    end
  end
end
