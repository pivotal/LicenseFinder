require 'json'
require 'tempfile'

module LicenseFinder
  class NPM < PackageManager
    def current_packages
      NpmPackage.packages_from_json(npm_json, package_path)
    end

    private

    def self.package_management_command
      'npm'
    end

    def package_path
      project_path.join('package.json')
    end

    def run_command_with_tempfile_buffer(command, &block)
      tempfile = Tempfile.new
      begin
        output, success = Dir.chdir(project_path) { capture("#{command} > #{tempfile.path}") }
        result = block.call(File.read(tempfile.path))
      ensure
        tempfile.close
        tempfile.unlink
      end
      [output, result, success]
    end

    def npm_json
      command = "#{NPM::package_management_command} list --json --long"
      output, json, success = run_command_with_tempfile_buffer(command, &:parse_json_safely)
      unless success
        if json
          $stderr.puts "Command '#{command}' returned an error but parsing succeeded."
        else
          raise "Command '#{command}' failed to execute: #{output}"
        end
      end
      json
    end
  end

  String.class_eval do
    def parse_json_safely
      JSON.parse(self) rescue nil
    end
  end

end
