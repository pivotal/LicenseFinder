# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'
require 'set'

module LicenseFinder
  describe Dotnet do
    it_behaves_like 'a PackageManager'

    describe '.package_management_command' do
      it 'returns the correct package management command' do
        expect(described_class.package_management_command).to eq('dotnet')
      end
    end

    describe '.prepare_command' do
      it 'returns the correct prepare command' do
        expect(described_class.prepare_command).to eq('dotnet restore')
      end
    end

    describe '.prepare', skip: LicenseFinder.broken_fakefs? do
      include FakeFS::SpecHelpers
      before do
        FileUtils.mkdir_p 'app/someproj'
        FileUtils.touch 'app/someproj/someproj.csproj'
      end

      it 'calls dotnet restore' do
        dotnet = Dotnet.new project_path: Pathname.new('app')
        expect(SharedHelpers::Cmd).to receive(:run).with('dotnet restore')
                                                   .and_return(['', '', cmd_success])
        dotnet.prepare
      end
    end

    describe '#current_packages', skip: LicenseFinder.broken_fakefs? do
      include FakeFS::SpecHelpers

      let(:assets_json1) do
        <<-A1
        {
          "libraries": {
            "Thing1/5.2.6": {
              "path": "",
              "type": "package",
              "files": []
            },
            "Thing2/1.2.3": {
              "path": "",
              "type": "package",
              "files": []
            }
          }
        }
        A1
      end

      let(:assets_json2) do
        <<-A2
        {
          "libraries": {
            "Thing3/5.2.6": {
              "path": "",
              "type": "package",
              "files": []
            },
            "Thing2/1.2.3": {
              "path": "",
              "type": "package",
              "files": []
            }
          }
        }
        A2
      end

      before do
        FileUtils.mkdir_p 'app/project'
        FileUtils.touch 'app/project/project1.csproj'
        FileUtils.mkdir_p 'app/project1/obj'
        FileUtils.mkdir_p 'app/project2/obj'
        File.write('app/project1/obj/project.assets.json', assets_json1)
        File.write('app/project2/obj/project.assets.json', assets_json2)
      end

      it 'lists all the packages used in a project' do
        dotnet = Dotnet.new project_path: Pathname.new('app')

        expected = [
          {
            name: 'Thing1',
            version: '5.2.6'
          },
          {
            name: 'Thing2',
            version: '1.2.3'
          },
          {
            name: 'Thing3',
            version: '5.2.6'
          }
        ]

        actual = dotnet.current_packages.map do |package|
          { name: package.name, version: package.version }
        end

        expect(actual).to contain_exactly(*expected)
      end

      describe 'When an assets file refers to a local project' do
        let(:assets_json2) do
          <<-A2
          {
            "libraries": {
              "someLocalProject/1.0.0": {
                "type": "project",
                "path": ""
              }
            }
          }
          A2
        end

        it 'ignores the project' do
          dotnet = Dotnet.new project_path: Pathname.new('app')
          actual = dotnet.current_packages
          expect(actual.map(&:name)).to match_array %w[Thing1 Thing2]
        end
      end
    end
  end

  describe Dotnet::AssetFile, skip: LicenseFinder.broken_fakefs? do
    include FakeFS::SpecHelpers

    before do
      File.write('project.assets.json', assets_json)
    end

    describe '#dependencies' do
      let(:assets_json) do
        <<-AJ
        {
          "version": 3,
          "libraries": {
            "Thing1/5.2.6": {
              "path": "thing1/5.2.6",
              "type": "package",
              "files": ["foo.nuspec"]
            },
            "Thing2/1.2.3": {
              "path": "thing1/5.2.6",
              "type": "package",
              "files": ["foo"]
            }
          },
          "packageFolders": {
            "packageFolder1": {},
            "packageFolder2": {}
          }
        }
        AJ
      end

      let(:expected_dependencies) do
        [
          Dotnet::PackageMetadata.new(
            'Thing1',
            '5.2.6',
            %w[packageFolder1/thing1/5.2.6/foo.nuspec packageFolder2/thing1/5.2.6/foo.nuspec]
          ),
          Dotnet::PackageMetadata.new('Thing2', '1.2.3', [])
        ]
      end

      it 'returns the list of packages' do
        asset_file = Dotnet::AssetFile.new('project.assets.json')
        expect(asset_file.dependencies).to eq(expected_dependencies)
      end
    end

    describe '#possible_spec_paths' do
      describe 'For a package with a nuspec file' do
        let(:assets_json) do
          <<-AJ
          {
            "version": 3,
            "libraries": {
              "Thing1/5.2.6": {
                "path": "thing1/5.2.6",
                "type": "package",
                "files": ["something.dll", "foo.nuspec"]
              }
            },
            "packageFolders": {
              "packageFolder1": {},
              "packageFolder2": {}
            }
          }
          AJ
        end

        it 'returns the nuspec file in each package folder' do
          asset_file = Dotnet::AssetFile.new('project.assets.json')
          expected = %w[packageFolder1/thing1/5.2.6/foo.nuspec packageFolder2/thing1/5.2.6/foo.nuspec]
          expect(asset_file.possible_spec_paths('Thing1/5.2.6')).to eq(expected)
        end
      end

      describe 'For a package without a nuspec file' do
        let(:assets_json) do
          <<-AJ
          {
            "version": 3,
            "libraries": {
              "Thing1/5.2.6": {
                "path": "thing1/5.2.6",
                "type": "package",
                "files": []
              }
            },
            "packageFolders": {
              "packageFolder1": {}
            }
          }
          AJ
        end

        it 'returns an empty array' do
          asset_file = Dotnet::AssetFile.new('project.assets.json')
          expect(asset_file.possible_spec_paths('Thing1/5.2.6')).to be_empty
        end
      end
    end
  end

  describe Dotnet::PackageMetadata do
    describe '#read_license_urls', skip: LicenseFinder.broken_fakefs? do
      include FakeFS::SpecHelpers

      before do
        File.write('foo.nuspec', nuspec_contents)
      end

      let(:nuspec_contents) do
        <<-NUSPEC
        <?xml version="1.0" encoding="utf-8"?>
          <package xmlns="http://schemas.microsoft.com/packaging/2013/05/nuspec.xsd">
            <metadata>
              <licenseUrl>http://www.microsoft.com/web/webpi/eula/net_library_eula_ENU.htm</licenseUrl>
            </metadata>
          </package>
        NUSPEC
      end

      it 'returns the license URL from each file that exists' do
        possible_paths = %w[bar.nuspec foo.nuspec]
        package_metadata = Dotnet::PackageMetadata.new('arbitrary', 'arbitrary', possible_paths)
        expected_url = 'http://www.microsoft.com/web/webpi/eula/net_library_eula_ENU.htm'
        expect(package_metadata.read_license_urls).to eq([expected_url])
      end
    end

    describe '#==' do
      it 'returns true when all attributes are equal' do
        metadata1 = Dotnet::PackageMetadata.new('A', 1.2, %w[foo bar])
        metadata2 = Dotnet::PackageMetadata.new('A', 1.2, %w[foo bar])
        expect(metadata1).to eq(metadata2)
      end

      it 'returns false when names are different' do
        metadata1 = Dotnet::PackageMetadata.new('A', 1.2, %w[foo bar])
        metadata2 = Dotnet::PackageMetadata.new('B', 1.2, %w[foo bar])
        expect(metadata1).to_not eq(metadata2)
      end

      it 'returns false when versions are different' do
        metadata1 = Dotnet::PackageMetadata.new('A', 1.2, %w[foo bar])
        metadata2 = Dotnet::PackageMetadata.new('A', 1.3, %w[foo bar])
        expect(metadata1).to_not eq(metadata2)
      end

      it 'returns false when possible_spec_paths are different' do
        metadata1 = Dotnet::PackageMetadata.new('A', 1.2, %w[foo bar])
        metadata2 = Dotnet::PackageMetadata.new('A', 1.2, %w[bar baz])
        expect(metadata1).to_not eq(metadata2)
      end
    end
  end
end
