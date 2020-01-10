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
      packages = []
      dependencies['default'].each do |name, data|
        version = canonicalize(data['version'])
        packages << PipPackage.new(name, version, PyPI.definition(name, version), groups: ['default'])
      end
      dependencies['develop'].each do |name, data|
        version = canonicalize(data['version'])
        if package = packages.find { |x| x.name == name && x.version == version }
          package.groups << 'develop'
        else
          packages << PipPackage.new(name, version, PyPI.definition(name, version), groups: ['develop'])
        end
      end
      packages
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
