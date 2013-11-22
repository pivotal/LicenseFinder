require 'json'
require 'httparty'

module LicenseFinder
  class PipPackage < Package
    def initialize(name, version, install_path)
      @name = name
      @version = version
      @install_path = install_path
    end

    attr_reader :name, :version

    def summary
      json.fetch("summary", "")
    end

    def description
      json.fetch("description", "")
    end

    def children
      [] # no way to determine child deps from pip (maybe?)
    end

    def groups
      [] # no concept of dev/test groups in pip (maybe?)
    end

    def homepage
      nil # no way to extract homepage from pip (maybe?)
    end

    private

    attr_reader :install_path

    def license_from_spec
      license = json.fetch("license", "UNKNOWN")

      if license == "UNKNOWN"
        classifiers = json.fetch("classifiers", [])
        license = classifiers.map do |c|
          if c.start_with?("License")
            c.gsub(/^License.*::\s*(.*)$/, '\1')
          end
        end.compact.first
      end

      license
    end

    def json
      return @json if @json

      response = HTTParty.get("https://pypi.python.org/pypi/#{name}/#{version}/json")
      if response.code == 200
        @json = JSON.parse(response.body).fetch("info", {})
      end

      @json ||= {}
    end
  end
end
