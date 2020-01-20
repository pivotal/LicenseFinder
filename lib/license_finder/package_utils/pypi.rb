# frozen_string_literal: true

require 'net/http'
require 'openssl'

module LicenseFinder
  class PyPI
    CONNECTION_ERRORS = [
      EOFError,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::EINVAL,
      Net::OpenTimeout,
      Net::ProtocolError,
      Net::ReadTimeout,
      OpenSSL::OpenSSLError,
      OpenSSL::SSL::SSLError,
      SocketError,
      Timeout::Error
    ].freeze

    class << self
      def definition(name, version)
        response = request("https://pypi.org/pypi/#{name}/#{version}/json")
        response.is_a?(Net::HTTPSuccess) ? JSON.parse(response.body).fetch('info', {}) : {}
      rescue *CONNECTION_ERRORS
        {}
      end

      def request(location, limit = 10)
        uri = URI(location)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.get(uri.request_uri).response
        response.is_a?(Net::HTTPRedirection) && limit.positive? ? request(response['location'], limit - 1) : response
      end
    end
  end
end
