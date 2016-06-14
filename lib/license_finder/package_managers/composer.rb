require 'json'

module LicenseFinder
  class Composer < PackageManager
    DEPENDENCY_GROUPS = ["require", "require-dev"]

    def initialize(options={})
      super
      @command = options[:composer_command] || "composer"
    end

    def current_packages
      packages = {}
      walk_dependency_tree(dep[:name]) do |name, dependency|
        package_id = name
        if packages[package_id] && packages[package_id].version.nil? && dependency["version"]
          old_package = packages[package_id]
          packages[package_id] = ComposerPackage.new(dependency, logger: logger, groups: old_package.groups)
        else
          packages[package_id] ||= ComposerPackage.new(dependency, logger: logger)
        end
      end
      packages.values
    end

    def self.package_management_command
      "composer"
    end

    def package_path
      project_path.join('composer.json')
    end

    def lockfile_path
      project_path.join('composer.lock')
    end

    def walk_dependency_tree(dependency, &block)
      @json ||= composer_json
      deps = @json.fetch("dependencies", {}).reject { |_,d| d.is_a?(String) }
    end

    def composer_json
      command = @command + "licenses --format=json"
      output, success = Dir.chdir(project_path) { capture(command) }

      if success
        json = JSON(output)
      else
        json = begin
                 JSON(output)
               rescue JSON::ParserError
                 nil
               end
        if json
          $stderr.puts "Command '#{command}' returned an error but parsing succeeded."
        else
          raise "Command '#{command}' failed to execute: #{output}"
        end
      end

      json
    end
  end
end
