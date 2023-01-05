# frozen_string_literal: true

require 'xmlsimple'
require 'license_finder/package_utils/maven_dependency_finder'

module LicenseFinder
  class Maven < PackageManager
    def initialize(options = {})
      super
      @ignored_groups = options[:ignored_groups]
      @include_groups = options[:maven_include_groups]
      @maven_options = options[:maven_options]
    end

    def current_packages
      # Generate a file "target/generated-resources/licenses.xml" that contains a list of
      # dependencies including their groupId, artifactId, version and license (name, file, url).
      # The license file downloaded this way, however, is a generic one without author information.
      # This file also does not contain further information about the package like its name,
      # description or website URL.
      command = "#{package_management_command} org.codehaus.mojo:license-maven-plugin:download-licenses"
      command += " -Dlicense.excludedScopes=#{@ignored_groups.to_a.join(',')}" if @ignored_groups && !@ignored_groups.empty?
      command += " #{@maven_options}" unless @maven_options.nil?
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      dependencies = MavenDependencyFinder.new(project_path, maven_repository_path).dependencies
      packages = dependencies.map do |dep|
        MavenPackage.new(dep, logger: logger, include_groups: @include_groups)
      end
      packages.uniq
    end

    def package_management_command
      wrapper = File.join(project_path, Platform.windows? ? 'mvnw.cmd' : 'mvnw')
      maven = 'mvn'

      File.exist?(wrapper) ? wrapper : maven
    end

    def possible_package_paths
      [project_path.join('pom.xml')]
    end

    def project_root?
      active? && root_module?
    end

    private

    def root_module?
      command = "#{package_management_command} help:evaluate -Dexpression=project.parent -q -DforceStdout"
      stdout, _stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute in #{project_path}: #{stdout}" unless status.success?

      stdout.include?('null object or invalid expression')
    end

    # Look up the path of the Maven repository (e.g. ~/.m2)
    def maven_repository_path
      command = "#{package_management_command} help:evaluate -Dexpression=settings.localRepository -q -DforceStdout"
      command += " #{@maven_options}" unless @maven_options.nil?
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      Pathname(stdout)
    end
  end
end
