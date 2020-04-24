# frozen_string_literal: true

require 'csv'
require 'license_finder/package_utils/sbt_dependency_finder'

module LicenseFinder
  class Sbt < PackageManager
    def initialize(options = {})
      super
      @include_groups = options[:sbt_include_groups]
    end

    def current_packages
      command = "#{package_management_command} dumpLicenseReport"
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      dependencies = SbtDependencyFinder.new(project_path).dependencies
      packages = dependencies.flat_map do |text|
        options = {
          headers: true
        }

        contents = CSV.parse(text, options)
        contents.map do |row|
          group_id, name, version = row['Dependency'].split('#').map(&:strip)
          spec = {
            'artifactId' => name,
            'groupId' => group_id,
            'version' => version,
            'licenses' => [{ 'name' => row['License'] }]
          }

          path = File.join("#{Dir.home}/.ivy2/cache", "#{spec['groupId']}/#{spec['artifactId']}")
          SbtPackage.new(spec, logger: logger, include_groups: @include_groups, install_path: path)
        end
      end

      packages.uniq
    end

    def package_management_command
      'sbt'
    end

    def possible_package_paths
      [project_path.join('build.sbt')]
    end
  end
end
