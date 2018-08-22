require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  def self.broken_fakefs?
    RUBY_PLATFORM =~ /java/ || RUBY_VERSION =~ /^(1\.9|2\.0)/
  end

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
        <<-EOF
        {
          "libraries": {
            "Thing1/5.2.6": {},
            "Thing2/1.2.3": {}
          }
        }
        EOF
      end

      let(:assets_json2) do
        <<-EOF
        {
          "libraries": {
            "Thing3/5.2.6": {},
            "Thing2/1.2.3": {}
          }
        }
        EOF
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
        actual = dotnet.current_packages

        expect(actual.map(&:name)).to match_array ['Thing1', 'Thing2', 'Thing3']
        expect(actual.map(&:version)).to match_array ['5.2.6', '1.2.3', '5.2.6']
      end
    end
  end

  describe Dotnet::AssetFile do
    describe '#packages', skip: LicenseFinder.broken_fakefs? do
      include FakeFS::SpecHelpers

      let(:assets_json) do
        <<-EOF
        {
          "version": 3,
          "libraries": {
            "Thing1/5.2.6": {
              "path": "thing1/5.2.6"
            },
            "Thing2/1.2.3": {
              "path": "thing1/5.2.6"
            }
          },
          "packageFolders": {
            "packageFolder1": {},
            "packageFolder2": {}
          }
        }
        EOF
      end

      before do
        File.write('project.assets.json', assets_json)
      end

      it 'returns the list of packages' do
        assetFile = Dotnet::AssetFile.new('project.assets.json')
        actual = assetFile.dependencies
        expect(actual.length).to eq(2)
        expect(actual[0].name).to eq('Thing1')
        expect(actual[0].version).to eq('5.2.6')
        expect(actual[1].name).to eq('Thing2')
        expect(actual[1].version).to eq('1.2.3')
      end
    end
  end
end