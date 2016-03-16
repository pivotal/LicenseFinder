require 'json'

module LicenseFinder
  class Bower < PackageManager
    def current_packages
      bower_output.map do |package|
        BowerPackage.new(package, logger: logger)
      end
    end

    def self.package_management_command
      "bower"
    end

    private

    def bower_output
      command = 'bower list --json -l action'
      output, success = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{output}" unless success

      JSON(output)
        .fetch("dependencies", {})
        .values
    end

    def package_path
      project_path.join('bower.json')
    end
  end
end
