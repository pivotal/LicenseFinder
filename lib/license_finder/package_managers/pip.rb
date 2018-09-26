# frozen_string_literal: true

require 'json'
require 'net/http'

module LicenseFinder
  class Pip < PackageManager
    def initialize(options = {})
      super
      @requirements_path = options[:pip_requirements_path] || Pathname('requirements.txt')
    end

    def current_packages
      pip_output.map do |name, version, children, location|
        PipPackage.new(
          name,
          version,
          pypi_def(name, version),
          logger: logger,
          children: children,
          install_path: Pathname(location).join(name)
        )
      end
    end

    def self.package_management_command
      'pip'
    end

    def self.prepare_command
      'pip install'
    end

    def prepare
      prep_cmd = "#{Pip.prepare_command} -r #{@requirements_path}"
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(prep_cmd) }
      return if status.success?

      log_errors stderr
      raise "Prepare command '#{prep_cmd}' failed" unless @prepare_no_fail
    end

    def possible_package_paths
      if project_path.nil?
        [@requirements_path]
      else
        [project_path.join(@requirements_path)]
      end
    end

    private

    def pip_output
      output = `#{LicenseFinder::BIN_PATH.join('license_finder_pip.py')} #{detected_package_path}`
      JSON(output).map do |package|
        package.values_at('name', 'version', 'dependencies', 'location')
      end
    end

    def pypi_def(name, version)
      response = pypi_request("https://pypi.org/pypi/#{name}/#{version}/json")
      response.is_a?(Net::HTTPSuccess) ? JSON.parse(response.body).fetch('info', {}) : {}
    end

    def pypi_request(location, limit = 10)
      uri = URI(location)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.get(uri.request_uri).response

      response.is_a?(Net::HTTPRedirection) && limit.positive? ? pypi_request(response['location'], limit - 1) : response
    end
  end
end
