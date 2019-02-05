# frozen_string_literal: true

require 'license_finder/package_utils/conan_info_parser'

module LicenseFinder
  class Conan < PackageManager
    def possible_package_paths
      [project_path.join('conanfile.txt')]
    end

    def current_packages
      install_command = 'conan install .'
      info_command = 'conan info .'
      Dir.chdir(project_path) { Cmd.run(install_command) }
      info_output, _stderr, _status = Dir.chdir(project_path) { Cmd.run(info_command) }

      info_parser = ConanInfoParser.new

      deps = info_parser.parse(info_output)
      deps.map do |dep|
        name, version = dep['name'].split('@').first.split('/')
        url = dep['URL']
        license_file_path = Dir.glob("#{project_path}/licenses/#{name}/**/LICENSE*").first
        ConanPackage.new(name, version, File.open(license_file_path).read, url) unless name == 'PROJECT'
      end.compact
    end
  end
end
