# frozen_string_literal: true

require 'json'

module LicenseFinder
  class Bower < PackageManager
    def current_packages
      bower_output.map do |package|
        BowerPackage.new(package, logger: logger)
      end
    end

    def package_management_command
      'bower'
    end

    def prepare_command
      'bower install'
    end

    def possible_package_paths
      [project_path.join('bower.json')]
    end

    private

    def bower_output
      command = "#{package_management_command} list --json -l action --allow-root"
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      JSON(stdout)
        .fetch('dependencies', {})
        .values
    end
  end
end
