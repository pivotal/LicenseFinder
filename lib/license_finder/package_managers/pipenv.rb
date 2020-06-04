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
      @current_packages ||=
        begin
          packages = {}
          each_dependency(groups: allowed_groups) do |name, data, group|
            version = canonicalize(data['version'] || 'unknown')
            package = packages.fetch(key_for(name, version)) do |key|
              packages[key] = build_package_for(name, version)
            end
            package.groups << group
          end
          packages.values
        end
    end

    def possible_package_paths
      project_path ? [project_path.join(@lockfile)] : [@lockfile]
    end

    private

    def each_dependency(groups: [])
      dependencies = JSON.parse(IO.read(detected_package_path))
      groups.each do |group|
        dependencies[group].each do |name, data|
          yield name, data, group
        end
      end
    end

    def canonicalize(version)
      version.sub(/^==/, '')
    end

    def build_package_for(name, version)
      PipPackage.new(name, version, PyPI.definition(name, version))
    end

    def key_for(name, version)
      "#{name}-#{version}"
    end

    def allowed_groups
      %w[default develop] - ignored_groups.to_a
    end

    def ignored_groups
      @ignored_groups || []
    end
  end
end
