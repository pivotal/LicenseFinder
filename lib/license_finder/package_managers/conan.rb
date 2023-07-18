# frozen_string_literal: true

require 'license_finder/package_utils/conan_info_parser'
require 'license_finder/package_utils/conan_info_parser_v2'

module LicenseFinder
  class Conan < PackageManager
    def possible_package_paths
      [project_path.join('conanfile.txt'), project_path.join('conanfile.py')]
    end

    def license_file_is_good?(license_file_path)
      !license_file_path.nil? && File.file?(license_file_path)
    end

    def license_file(project_path, name)
      candidates = Dir.glob("#{project_path}/licenses/#{name}/**/LICENSE*")
      candidates.each do |candidate|
        return candidate if license_file_is_good?(candidate)
      end
      nil
    end

    def deps_list_conan_v1(project_path)
      info_command = 'conan info .'
      info_output, _stderr, _status = Dir.chdir(project_path) { Cmd.run(info_command) }
      return nil if info_output.empty?

      info_parser = ConanInfoParser.new
      info_parser.parse(info_output)
    end

    def deps_list_conan_v2(project_path)
      info_command = 'conan graph info .'
      info_output, stderr, _status = Dir.chdir(project_path) { Cmd.run(info_command) }
      if info_output.empty?
        return if stderr.empty?

        info_output = stderr
      end
      info_parser = ConanInfoParserV2.new
      info_parser.parse(info_output)
    end

    def deps_list(project_path)
      deps = deps_list_conan_v1(project_path)
      deps = deps_list_conan_v2(project_path) if deps.nil? || deps.empty?
      deps
    end

    def current_packages
      install_command = 'conan install .'
      Dir.chdir(project_path) { Cmd.run(install_command) }

      deps = deps_list(project_path)
      return [] if deps.nil?

      deps.map do |dep|
        name, version = dep['name'].split('/')
        license_file_path = license_file(project_path, name)

        next unless license_file_is_good?(license_file_path)

        url = dep['homepage']
        url = dep['url'] if url.nil?
        ConanPackage.new(name, version, File.open(license_file_path).read, url)
      end.compact
    end
  end
end
