require 'json'
require 'tempfile'

module LicenseFinder
  class NPM < PackageManager
    def current_packages
      NpmPackage.packages_from_json(npm_json, detected_package_path)
    end

    private

    def self.package_management_command
      'npm'
    end

    def possible_package_paths
      [project_path.join('package.json')]
    end

    def npm_json
      command = "#{NPM::package_management_command} list --json --long"
      stdout, stderr, exitstatus = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless exitstatus == 0

      JSON.parse(stdout)
    end
  end

end
