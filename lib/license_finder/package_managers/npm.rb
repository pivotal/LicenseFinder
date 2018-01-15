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

    private

    def npm_json
      command = "#{NPM.package_management_command} list --json --long"
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      JSON.parse(stdout)
    end
  end
end
