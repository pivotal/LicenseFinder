# frozen_string_literal: true

require 'json'

module LicenseFinder
  class Composer < PackageManager
    SHELL_COMMAND = 'composer licenses --format=json'

    def possible_package_paths
      [project_path.join('composer.lock'), project_path.join('composer.json')]
    end

    def current_packages
      dependency_list.map do |name, dependency|
        ComposerPackage.new(name, dependency['version'], spec_licenses: dependency['license'])
      end
    end

    def prepare
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(Composer.prepare_command) }
      return if status.success?

      log_errors stderr
      raise "Prepare command '#{Composer.prepare_command}' failed" unless @prepare_no_fail
    end

    def self.package_management_command
      'composer'
    end

    def self.prepare_command
      'composer install'
    end

    def package_path
      project_path.join('composer.json')
    end

    def lockfile_path
      project_path.join('composer.lock')
    end

    def dependency_list
      json ||= composer_json
      json.fetch('dependencies', {}).reject { |_, d| d.is_a?(String) }
    end

    def composer_json
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(Composer::SHELL_COMMAND) }
      raise "Command '#{Composer::SHELL_COMMAND}' failed to execute: #{stderr}" unless status.success?

      JSON(stdout)
    end
  end
end
