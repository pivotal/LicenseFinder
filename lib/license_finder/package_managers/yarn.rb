# frozen_string_literal: true

module LicenseFinder
  class Yarn < PackageManager
    SHELL_COMMAND = 'yarn licenses list --json'

    def possible_package_paths
      [project_path.join('yarn.lock')]
    end

    def current_packages
      #keeping the use of yarn1_production_flag here because the license plugin supports same commands as licenses in yarn v1
      cmd = "#{Yarn::SHELL_COMMAND}#{yarn1_production_flag}"
      unless yarn2_project?
        cmd += " --no-progress"
        suffix = " --cwd #{project_path}" unless project_path.nil?
        cmd += suffix unless suffix.nil?
      end

      stdout, stderr, status = Cmd.run(cmd)
      raise "Command '#{cmd}' failed to execute: #{stderr}" unless status.success?

      packages = []
      incompatible_packages = []

      json_strings = stdout.encode('ASCII', invalid: :replace, undef: :replace, replace: '?').split("\n")
      json_objects = json_strings.map { |json_object| JSON.parse(json_object) }

      if json_objects.last['type'] == 'table'
        license_json = json_objects.pop['data']
        packages = packages_from_json(license_json)
      end

      json_objects.each do |json_object|
        match = /(?<name>[\w,\-]+)@(?<version>(\d+\.?)+)/ =~ json_object['data'].to_s
        if match
          package = YarnPackage.new(name, version, spec_licenses: ['unknown'])
          incompatible_packages.push(package)
        end
      end

      packages + incompatible_packages.uniq
    end

    def prepare
      prep_cmd = prepare_command.to_s
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(prep_cmd) }
      return if status.success?

      log_errors stderr
      raise "Prepare command '#{prep_cmd}' failed" unless @prepare_no_fail
    end

    def self.takes_priority_over
      NPM
    end

    def package_management_command
      'yarn'
    end

    def prepare_command
      if yarn2_project?
        yarn2_prepare_command
      else
        yarn1_prepare_command
      end
    end

    private

    def yarn2_prepare_command
      # yarn v2 needs to use plugin version v0.6.0 or earlier
      license_plugin = "https://raw.githubusercontent.com/mhassan1/yarn-plugin-licenses/v0.6.0/bundles/@yarnpkg/plugin-licenses.js"
      if yarn3_project?
        license_plugin = "https://raw.githubusercontent.com/mhassan1/yarn-plugin-licenses/v0.7.2/bundles/@yarnpkg/plugin-licenses.js"
      end
      "#{yarn2_production_flag}yarn install && yarn plugin import #{license_plugin}"
    end

    def yarn1_prepare_command
      "yarn install --ignore-engines --ignore-scripts#{yarn1_production_flag}"
    end

    def yarn2_project?
      Dir.chdir(project_path) do
        version_string, stderr_str, status = Cmd.run('yarn -v')
        raise "Command 'yarn -v' failed to execute: #{stderr_str}" unless status.success?

        version = version_string.split('.').map(&:to_i)
        return version[0] >= 2
      end
    end

    def yarn3_project?
      Dir.chdir(project_path) do
        version_string, stderr_str, status = Cmd.run('yarn -v')
        raise "Command 'yarn -v' failed to execute: #{stderr_str}" unless status.success?

        version = version_string.split('.').map(&:to_i)
        return version[0] >= 3
      end
    end

    def packages_from_json(json_data)
      body = json_data['body']
      head = json_data['head']

      packages = body.map do |json_package|
        Hash[head.zip(json_package)]
      end

      valid_packages = filter_yarn_internal_package(packages)

      valid_packages.map do |package_hash|
        YarnPackage.new(
          package_hash['Name'],
          package_hash['Version'],
          spec_licenses: [package_hash['License']],
          homepage: package_hash['VendorUrl'],
          authors: package_hash['VendorName'],
          install_path: project_path.join(modules_folder, package_hash['Name'])
        )
      end
    end

    def modules_folder
      return @modules_folder if @modules_folder

      stdout, _stderr, status = Cmd.run('yarn config get modules-folder')
      @modules_folder = 'node_modules' if !status.success? || stdout.strip == 'undefined'
      @modules_folder ||= stdout.strip
    end

    # remove fake package created by yarn [Yarn Bug]
    def filter_yarn_internal_package(all_packages)
      internal_package_pattern = /workspace-aggregator-[a-zA-z0-9]{8}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{12}/
      yarn_internal_package = all_packages.find { |package| internal_package_pattern.match(package['Name']) }
      all_packages - [yarn_internal_package]
    end

    def yarn1_production_flag
      return '' if @ignored_groups.nil?

      @ignored_groups.include?('devDependencies') ? ' --production' : ''
    end

    def yarn2_production_flag
      return '' if @ignored_groups.nil?

      @ignored_groups.include?('devDependencies') ? 'yarn plugin import workspace-tools && yarn workspaces focus --all --production && ' : ''
    end
  end
end
