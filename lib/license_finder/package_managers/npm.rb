require 'json'
require 'tempfile'

module LicenseFinder
  class NPM < PackageManager
    def current_packages
      NpmPackage.packages_from_json(npm_json, detected_package_path)
    end

    def self.package_management_command
      'npm'
    end

    def self.prepare_command
      'npm install'
    end

    def possible_package_paths
      [project_path.join('package.json')]
    end

    def prepare
      prep_cmd = "#{NPM.prepare_command}#{production_flag}"
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(prep_cmd) }
      return if status.success?
      log_errors stderr
      raise "Prepare command '#{prep_cmd}' failed" unless @prepare_no_fail
    end

    private

    def npm_json
      command = "#{NPM.package_management_command} list --json --long#{production_flag}"
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      JSON.parse(stdout)
    end

    def production_flag
      return '' if @ignored_groups.nil?
      @ignored_groups.include?('devDependencies') ? ' --production' : ''
    end
  end
end
