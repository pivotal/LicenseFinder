require 'json'

module LicenseFinder
  class NPM < PackageManager
    DEPENDENCY_GROUPS = ["dependencies", "devDependencies", "bundleDependencies", "bundledDependencies"]

    def current_packages
      json = npm_json
      dependencies = DEPENDENCY_GROUPS.map { |g| (json[g] || {}).values }.flatten(1).reject{ |d| d.is_a?(String) }

      pkgs = {} # name => spec
      dependencies.each { |d| recursive_dependencies(d, pkgs) }
      pkgs.values.map { |d| NpmPackage.new(d, logger: logger) }
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

    # node_module can be empty hash if it is included elsewhere
    def recursive_dependencies(node_module, memo)
      key = node_module['name']
      memo[key] ||= {}
      memo[key].merge!(node_module)
      node_module.fetch('dependencies', {}).each do |dep_key, data|
        data['name'] ||= dep_key
        recursive_dependencies(data, memo)
      end
      memo
    end
  end
end
