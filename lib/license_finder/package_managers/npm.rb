require 'json'

module LicenseFinder
  class NPM < PackageManager
    DEPENDENCY_GROUPS = ["dependencies", "devDependencies"]

    def current_packages
      packages = {}
      direct_dependencies.each do |dep|
        group_name = dep[:group]
        walk_dependency_tree(dep[:name]) do |dependency|
          package_id = dependency["name"]
          packages[package_id] ||= NpmPackage.new(dependency, logger: logger)
          packages[package_id].groups << group_name unless packages[package_id].groups.include?(group_name)
        end
      end
      packages.values
    end

    private

    def direct_dependencies
      package_json = JSON.parse(File.read(package_path))
      DEPENDENCY_GROUPS.map do |group|
        package_json.fetch(group, {}).keys.map do |dependency|
          {
            group: group,
            name: dependency
          }
        end
      end.flatten
    end

    def walk_dependency_tree(dependency, &block)
      @json ||= npm_json
      deps = @json.fetch("dependencies", {}).reject { |_,d| d.is_a?(String) }
      current_dep = deps[dependency]
      block.call(current_dep) if current_dep
      recursive_dependencies(current_dep) do |d|
        block.call(d)
      end
    end

    def npm_json
      command = 'npm list --json --long'
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

    def package_path
      project_path.join('package.json')
    end

    def recursive_dependencies(node_module, &block)
      return unless node_module # node_module can be empty hash if it is included elsewhere
      block.call(node_module)
      node_module.fetch('dependencies', {}).each do |dep_key, data|
        data['name'] ||= dep_key
        recursive_dependencies(data, &block)
      end
    end
  end
end
