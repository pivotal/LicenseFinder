# frozen_string_literal: true

require 'json'
require 'license_finder/package_utils/pypi'

module LicenseFinder
  class Pipenv < PackageManager
    def initialize(options = {})
      super
      @lockfile = Pathname('Pipfile.lock')
    end

    def current_packages
      dependencies['default'].map do |name, data|
        PipPackage.new(name, canonicalize(data['version']))
      end
    end

    def possible_package_paths
      project_path ? [project_path.join(@lockfile)] : [@lockfile]
    end

    private

    def dependencies
      @dependencies ||= JSON.parse(IO.read(detected_package_path))
    end

    def canonicalize(version)
      version.sub(/^==/, '')
    end
  end
end
