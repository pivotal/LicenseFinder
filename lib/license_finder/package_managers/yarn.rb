# frozen_string_literal: true

module LicenseFinder
  class Yarn < PackageManager
    def initialize(options = {})
      super
      @yarn_options = options[:yarn_options]
    end

    SHELL_COMMAND = 'yarn licenses list --recursive --json'

    def possible_package_paths
      [project_path.join('yarn.lock')]
    end

    def current_packages
      # the licenses plugin supports the classic production flag
      cmd = "#{Yarn::SHELL_COMMAND}#{classic_yarn_production_flag}"
      if yarn_version == 1
        cmd += ' --no-progress'
        cmd += " --cwd #{project_path}" unless project_path.nil?
        cmd += " #{@yarn_options}" unless @yarn_options.nil?
      end

      stdout, stderr, status = Cmd.run(cmd)
      raise "Command '#{cmd}' failed to execute: #{stderr}" unless status.success?

      json_strings = stdout.encode('ASCII', invalid: :replace, undef: :replace, replace: '?').split("\n")
      json_objects = json_strings.map { |json_object| JSON.parse(json_object) }

      if yarn_version == 1
        get_yarn1_packages(json_objects)
      else
        get_yarn_packages(json_objects)
      end
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
      if yarn_version == 1
        classic_yarn_prepare_command
      else
        yarn_prepare_command
      end
    end

    private

    def yarn_prepare_command
      "#{yarn_plugin_production_command}yarn install && yarn plugin import https://raw.githubusercontent.com/mhassan1/yarn-plugin-licenses/#{yarn_licenses_plugin_version}/bundles/@yarnpkg/plugin-licenses.js"
    end

    def classic_yarn_prepare_command
      "yarn install --ignore-engines --ignore-scripts#{classic_yarn_production_flag}"
    end

    def yarn_licenses_plugin_version
      if yarn_version == 2
        'v0.6.0'
      else
        'v0.7.2'
      end
    end

    def yarn_version
      Dir.chdir(project_path) do
        version_string, stderr_str, status = Cmd.run('yarn -v')
        raise "Command 'yarn -v' failed to execute: #{stderr_str}" unless status.success?

        version = version_string.split('.').map(&:to_i)
        return version[0]
      end
    end

    def get_yarn_packages(json_objects)
      packages = []
      incompatible_packages = []
      json_objects.each do |json_object|
        license = json_object['value']
        body = json_object['children']

        body.each do |package_name, vendor_info|
          valid_match = %r{(?<name>[@,\w,\-,/,.]+)@(?<manager>\D*):\D*(?<version>(\d+\.?)+)} =~ package_name.to_s
          valid_match = %r{(?<name>[@,\w,\-,/,.]+)@virtual:.+#(\D*):\D*(?<version>(\d+\.?)+)} =~ package_name.to_s if manager.eql?('virtual')

          if valid_match
            homepage = vendor_info['children']['vendorUrl']
            author = vendor_info['children']['vendorName']
            package = YarnPackage.new(
              name,
              version,
              spec_licenses: [license],
              homepage: homepage,
              authors: author,
              install_path: project_path.join(modules_folder, name)
            )
            packages << package
          end
          incompatible_match = /(?<name>[\w,\-]+)@[a-z]*:(?<version>(\.))/ =~ package_name.to_s

          if incompatible_match
            package = YarnPackage.new(name, version, spec_licenses: ['unknown'])
            incompatible_packages.push(package)
          end
        end
      end

      packages + incompatible_packages.uniq
    end

    def get_yarn1_packages(json_objects)
      packages = []
      incompatible_packages = []
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

    def classic_yarn_production_flag
      return '' if @ignored_groups.nil?

      @ignored_groups.include?('devDependencies') ? ' --production' : ''
    end

    def yarn_plugin_production_command
      return '' if @ignored_groups.nil?

      @ignored_groups.include?('devDependencies') ? 'yarn plugin import workspace-tools && yarn workspaces focus --all --production && ' : ''
    end
  end
end
