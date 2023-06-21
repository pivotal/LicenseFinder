# frozen_string_literal: true

require 'license_finder/package_utils/conan_info_parser'

module LicenseFinder
  class Conan < PackageManager
    def possible_package_paths
      [project_path.join('conanfile.txt')]
    end

    def license_file_is_good?(license_file_path)
      license_file_path != nil && File.file?(license_file_path)
    end

    def license_file(project_path, name)
      candidates = Dir.glob("#{project_path}/licenses/#{name}/**/LICENSE*")
      candidates.each do |candidate|
        if license_file_is_good?(candidate)
          return candidate
        end
      end
      nil
    end

    def current_packages
      install_command = 'conan install .'
      info_command = 'conan info .'
      Dir.chdir(project_path) { Cmd.run(install_command) }
      info_output, _stderr, _status = Dir.chdir(project_path) { Cmd.run(info_command) }

      info_parser = ConanInfoParser.new

      deps = info_parser.parse(info_output)
      deps.map do |dep|
        name, version = dep['name'].split('/')
        license_file_path = license_file(project_path, name)

        unless license_file_is_good?(license_file_path)
          next
        end

        url = dep['URL']
        ConanPackage.new(name, version, File.open(license_file_path).read, url)
      end.compact
    end
  end
end
