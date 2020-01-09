# frozen_string_literal: true

require 'net/http'

module LicenseFinder
  class PyPI
    class << self
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
end
