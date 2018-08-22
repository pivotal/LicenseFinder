require 'pathname'
require 'json'

module LicenseFinder
  class Dotnet < PackageManager
    class AssetFile
      def initialize(path)
        @path = path
      end

      def dependencies
        manifest = JSON.parse(File.read(@path))
        manifest.fetch('libraries').keys.map do |name|
          parts = name.split('/')
          NugetPackage.new(parts[0], parts[1])
        end
      end
    end

    def possible_package_paths
      paths = Dir[project_path.join('**/*.csproj')]
      paths.map {|p| Pathname(p)}
    end

    def current_packages
      deps = asset_files.flat_map do |path|
        AssetFile.new(path).dependencies
      end
      deps.uniq {|d| [d.name, d.version]}
    end

    def asset_files
      Dir[project_path.join('**/project.assets.json')]
    end

    def self.package_management_command
      'dotnet'
    end

    def self.prepare_command
      "#{package_management_command} restore"
    end
  end
end