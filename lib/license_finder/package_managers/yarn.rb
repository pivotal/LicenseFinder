module LicenseFinder
  class Yarn < PackageManager
    SHELL_COMMAND = 'yarn licenses list --no-progress --json'

    def possible_package_paths
      [project_path.join('yarn.lock')]
    end

    def current_packages
      output, success = capture(Yarn::SHELL_COMMAND)
      return [] unless success

      packages = []
      incompatiblePackages = []

      json_strings = output.split("\n")
      json_objects = json_strings.map { |json_object| JSON.parse(json_object) }

      if json_objects.last['type'] == 'table'
        license_json = json_objects.pop['data']
        body = license_json['body']
        head = license_json['head']

        packages = body.map do |json_package|
          Hash[head.zip(json_package)]
        end.map do |package_hash|
          Package.new(package_hash['Name'], package_hash['Version'], {spec_licenses: [package_hash['License']], homepage: package_hash['VendorUrl']})
        end
      end

      json_objects.each do |json_object|
        match = (/(?<name>[\w,\-]+)@(?<version>(\d+\.?)+)/) =~ json_object['data'].to_s
        if match
          package = Package.new(name, version, {spec_licenses: ['unknown']})
          incompatiblePackages.push(package)
        end
      end

      packages + incompatiblePackages.uniq
    end

    def self.takes_priority_over
      NPM
    end

    def self.package_management_command
      'yarn'
    end

    def self.prepare_method
      'yarn install'
    end
  end
end
