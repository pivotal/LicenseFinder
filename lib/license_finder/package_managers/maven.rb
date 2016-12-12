require "xmlsimple"
require_relative "maven_dependency_finder"

module LicenseFinder
  class Maven < PackageManager
    def initialize(options={})
      super
      @ignore_groups = options[:ignore_groups]
      @include_groups = options[:maven_include_groups]
    end

    def current_packages
      command = "#{package_management_command} license:download-licenses"
      command += " -Dlicense.excludedScopes=#{@ignore_groups.to_a.join(',')}" if @ignore_groups and !@ignore_groups.empty?

      output, success = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{output}" unless success

      dependencies = MavenDependencyFinder.new(project_path).dependencies
      packages = dependencies.flat_map do |xml|
        options = {
          'GroupTags' => { 'licenses' => 'license', 'dependencies' => 'dependency' },
          'ForceArray' => ['license', 'dependency']
        }
        contents = XmlSimple.xml_in(xml, options)["dependencies"]
        contents.map do |dep|
          MavenPackage.new(dep, logger: logger, include_groups: @include_groups)
        end
      end
      packages.uniq
    end

    def package_management_command
      if Platform.windows?
        wrapper = 'mvnw.cmd'
        maven = 'mvn'
      else
        wrapper = './mvnw'
        maven = 'mvn'
      end

      File.exist?(File.join(project_path, wrapper)) ? wrapper : maven
    end

    private

    def package_path
      project_path.join('pom.xml')
    end
  end
end
