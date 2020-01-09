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
      content = IO.read(detected_package_path)
      dependencies = JSON.parse(content)
      dependencies['default'].map do |name, value|
        version = value['version'].sub(/^==/, '')
        PipPackage.new(name, version, PyPI.pypi_def(name, version))
      end
    end

    def possible_package_paths
      project_path ? [project_path.join(@lockfile)] : [@lockfile]
    end
  end
end
