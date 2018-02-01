module LicenseFinder
  class Yarn < PackageManager
    SHELL_COMMAND = 'yarn licenses list --no-progress --json'.freeze

    def possible_package_paths
      [project_path.join('yarn.lock')]
    end

    def current_packages
      cmd = "#{Yarn::SHELL_COMMAND}#{production_flag}"
      suffix = " --cwd #{project_path}" unless project_path.nil?
      cmd += suffix unless suffix.nil?

      stdout, _stderr, status = Cmd.run(cmd)
      return [] unless status.success?

      packages = []
      incompatible_packages = []

      json_strings = stdout.split("\n")
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
      prep_cmd = "#{Yarn.prepare_command}#{production_flag}"
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(prep_cmd) }
      return if status.success?
      log_errors stderr
      raise "Prepare command '#{prep_cmd}' failed" unless @prepare_no_fail
    end

    def self.takes_priority_over
      NPM
    end

    def self.package_management_command
      'yarn'
    end

    def self.prepare_command
      'yarn install'
    end

    private

    def packages_from_json(json_data)
      body = json_data['body']
      head = json_data['head']

      packages = body.map do |json_package|
        Hash[head.zip(json_package)]
      end

      packages.map do |package_hash|
        YarnPackage.new(package_hash['Name'], package_hash['Version'], spec_licenses: [package_hash['License']], homepage: package_hash['VendorUrl'])
      end
    end

    def production_flag
      return '' if @ignored_groups.nil?
      @ignored_groups.include?('devDependencies') ? ' --production' : ''
    end
  end
end
