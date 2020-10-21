# frozen_string_literal: true

require 'pathname'
require 'json'

module LicenseFinder
  class Dotnet < PackageManager
    class AssetFile
      def initialize(path)
        @manifest = JSON.parse(File.read(path))
      end

      def dependencies
        libs = @manifest.fetch('libraries').reject do |_, v|
          v.fetch('type') == 'project'
        end

        libs.keys.map do |name|
          parts = name.split('/')
          PackageMetadata.new(parts[0], parts[1], possible_spec_paths(name))
        end
      end

      def possible_spec_paths(package_key)
        lib = @manifest.fetch('libraries').fetch(package_key)
        spec_filename = lib.fetch('files').find { |f| f.end_with?('.nuspec') }
        return [] if spec_filename.nil?

        @manifest.fetch('packageFolders').keys.map do |root|
          Pathname(root).join(lib.fetch('path'), spec_filename).to_s
        end
      end
    end

    class PackageMetadata
      attr_reader :name, :version, :possible_spec_paths

      def initialize(name, version, possible_spec_paths)
        @name = name
        @version = version
        @possible_spec_paths = possible_spec_paths
      end

      def read_license_urls
        possible_spec_paths.flat_map do |path|
          Nuget.nuspec_license_urls(File.read(path)) if File.exist? path
        end.compact
      end

      def ==(other)
        other.name == name && other.version == version && other.possible_spec_paths == possible_spec_paths
      end
    end

    def possible_package_paths
      paths = Dir[project_path.join('*.csproj')]
      paths.map { |p| Pathname(p) }
    end

    def current_packages
      package_metadatas = asset_files
                          .flat_map { |path| AssetFile.new(path).dependencies }
                          .uniq { |d| [d.name, d.version] }

      package_metadatas.map do |d|
        path = Dir.glob("#{Dir.home}/.nuget/packages/#{d.name.downcase}/#{d.version}").first
        NugetPackage.new(d.name, d.version, spec_licenses: d.read_license_urls, install_path: path)
      end
    end

    def asset_files
      Dir[project_path.join('**/project.assets.json')]
    end

    def package_management_command
      'dotnet'
    end

    def prepare_command
      "#{package_management_command} restore"
    end
  end
end
