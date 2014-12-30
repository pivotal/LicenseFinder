require 'json'

module LicenseFinder
  class NPM < PackageManager
    DEPENDENCY_GROUPS = ["dependencies", "devDependencies"]

    def current_packages
      json = npm_json
      dependencies = DEPENDENCY_GROUPS.map { |g| (json[g] || {}).values }.flatten(1).reject{ |d| d.is_a?(String) }

      dependencies.map do |node_module|
        NpmPackage.new(node_module, logger: logger)
      end
    end

    private

    def npm_json
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

    def capture(command)
      [`#{command}`, $?.success?]
    end

    def package_path
      Pathname.new('package.json')
    end
  end
end
