# frozen_string_literal: true

require 'json'

module LicenseFinder
  class Pipenv < PackageManager
    def initialize(options = {})
      super
      @lockfile = Pathname('Pipfile.lock')
    end

    def current_packages
      content = IO.read(detected_package_path)
      dependencies = JSON.parse(content)
      dependencies['default'].map do |name, value|
        version = value['version'].sub(/^==/, '')
        PipPackage.new(name, version, pypi_def(name, version))
      end
    end

    def possible_package_paths
      project_path ? [project_path.join(@lockfile)] : [@lockfile]
    end

    private

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
