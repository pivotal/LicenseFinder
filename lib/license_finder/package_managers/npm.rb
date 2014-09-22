require 'json'

module LicenseFinder
  class NPM
    DEPENDENCY_GROUPS = ["dependencies", "devDependencies"]

    def self.current_packages
      json = npm_json
      dependencies = DEPENDENCY_GROUPS.map { |g| (json[g] || {}).values }.flatten(1).reject{ |d| d.is_a?(String) }

      dependencies.map do |node_module|
        NpmPackage.new(node_module)
      end
    end

    def self.active?
      package_path.exist?
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
          $stderr.puts "Command #{command} returned error but parsing succeeded." unless ENV['test_run']
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
      Pathname.new('package.json')
    end
  end
end
