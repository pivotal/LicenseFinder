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
      each_dependency do |name, data, group|
        version = canonicalize(data['version'])
        if package = packages.find { |x| x.name == name && x.version == version }
          package.groups << group
        else
          packages.push(build_package_for(name, version, [group]))
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

    def each_dependency(groups: ['default', 'develop'])
      groups.each do |group|
        dependencies[group].each do |name, data|
          yield name, data, group
        end
      end
    end

    def canonicalize(version)
      version.sub(/^==/, '')
    end

    def build_package_for(name, version, groups)
      PipPackage.new(name, version, PyPI.definition(name, version), groups: groups)
    end
  end
end
