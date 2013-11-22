require 'json'
require 'license_finder/package'

module LicenseFinder
  class NPM

    DEPENDENCY_GROUPS = ["dependencies", "devDependencies", "bundleDependencies", "bundledDependencies"]

    def self.current_modules
      return @modules if @modules

      json = npm_json
      dependencies = DEPENDENCY_GROUPS.map { |g| (json[g] || {}).values }.flatten(1).reject{ |d| d.is_a?(String) }

      @modules = dependencies.map do |node_module|
        NpmPackage.new(node_module)
      end
    end

    def self.has_package?
      File.exists?(package_path)
    end

    private

    def self.npm_json
      command = "npm list --json --long"
      output, success = capture(command)
      if success
        json = JSON(output)
      else
        json = JSON(output) rescue nil
        if json
          $stderr.puts "Command #{command} returned error but parsing succeeded."
        else
          raise "Command #{command} failed to execute: #{output}"
        end
      end
      json
    end

    def self.capture(command)
      [`#{command}`, $?.success?]
    end

    def self.package_path
      Pathname.new('package.json').expand_path
    end
  end
end
