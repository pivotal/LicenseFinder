require 'json'

 module LicenseFinder
  class Composer < PackageManager
    SHELL_COMMAND = 'composer licenses --format=json'

    def possible_package_paths
      [project_path.join('composer.lock')]
    end

    def current_packages
      packages = {}
      dependency_list.each do |name, dependency|
        package_id = name
        dependency['name'] = name
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

    def dependency_list
      json ||= composer_json
      json.fetch("dependencies", {}).reject { |_,d| d.is_a?(String) }
    end

    def composer_json
      cmd = "#{Composer::SHELL_COMMAND}#{production_flag}"
      suffix = " --working-dir #{project_path}" unless project_path.nil?
      cmd += suffix unless suffix.nil?

      stdout, _stderr, status = Cmd.run(cmd)
      return [] unless status.success?

      json = JSON(stdout)

      json
    end

    private

    def production_flag
      return '' if @ignored_groups.nil?

      @ignored_groups.include?('devDependencies') ? ' --no-dev' : ''
    end
  end
end
