# frozen_string_literal: true

module LicenseFinder
  class Erlangmk < PackageManager
    def current_packages
      deps.map do |path|
        ErlangmkPackage.new_from_path(path)
      end
    end

    def self.package_management_command
      "make"
    end

    def prepare_command
      "#{run} deps"
    end

    def possible_package_paths
      [
        project_path.join("Erlang.mk"),
        project_path.join("erlang.mk")
      ]
    end

    private

    def run
      self.class.package_management_command
    end

    def deps
      command = "#{run} show-deps"
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      stdout
        .each_line
        .map { |line| line.split(' ') }
    end
  end
end
