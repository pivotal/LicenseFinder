# frozen_string_literal: true

require 'json'

module LicenseFinder
  class Composer < PackageManager
    def initialize(options = {})
      super
      @check_require_only = !!options[:composer_check_require_only]
    end

    def possible_package_paths
      [project_path.join('composer.lock'), project_path.join('composer.json')]
    end

    def current_packages
      dependency_list.map do |name, dependency|
        path_command = "composer show #{name} -P"
        stdout, _stderr, status = Dir.chdir(project_path) { Cmd.run(path_command) }

        path = status.success? ? stdout.split(' ').last : ''
        ComposerPackage.new(name, dependency['version'], spec_licenses: dependency['license'], install_path: path)
      end
    end

    def prepare
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(prepare_command) }
      return if status.success?

      log_errors stderr
      raise "Prepare command '#{Composer.prepare_command}' failed" unless @prepare_no_fail
    end

    def package_management_command
      'composer'
    end

    def prepare_command
      'composer install --no-plugins --no-scripts --ignore-platform-reqs --no-interaction'
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
      command = "composer licenses --format=json#{@check_require_only ? ' --no-dev' : ''}"
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      JSON(stdout)
    end
  end
end
