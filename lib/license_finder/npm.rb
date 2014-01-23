require 'json'
require 'license_finder/package'

module LicenseFinder
  class NPM

    DEPENDENCY_GROUPS = ["dependencies", "devDependencies", "bundleDependencies", "bundledDependencies"]

    def self.current_modules
      return @modules if @modules

      command = "npm list --json --long"
      output, success = capture(command)
      raise "Command #{command} failed to execute: #{output}" unless success

      json = JSON(output)
      dependencies = DEPENDENCY_GROUPS.map do |g|
        found = (json[g] || {})
        found.map { |k,v| v.is_a?(String) ? {"name" => k, "version" => v} : v }
      end.flatten(1)

      @modules = dependencies.map do |node_module|
        Package.new(OpenStruct.new(
          :name => node_module.fetch("name", nil),
          :version => node_module.fetch("version", nil),
          :full_gem_path => node_module.fetch("path", nil),
          :license => self.harvest_license(node_module),
          :summary => node_module.fetch("description", nil),
          :description => node_module.fetch("readme", nil)
        ))
      end
    end

    def self.has_package?
      File.exists?(package_path)
    end

    private

    def self.capture(command)
      [`#{command}`, $?.success?]
    end

    def self.package_path
      Pathname.new('package.json').expand_path
    end

    def self.harvest_license(node_module)
      license = node_module.fetch("licenses", []).first

      if license.is_a? Hash
        license = license.fetch("type", nil)
      end

      if license.nil?
        license = node_module.fetch("license", nil)

        if license.is_a? Hash
          license = license.fetch("type", nil)
        end
      end

      license
    end
  end
end
