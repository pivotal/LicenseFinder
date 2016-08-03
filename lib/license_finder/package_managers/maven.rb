require "xmlsimple"
require_relative "maven_dependency_finder"

module LicenseFinder
  class Maven < PackageManager
    def current_packages
      command = "#{Maven::package_management_command} license:download-licenses"
      output, success = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{output}" unless success

      xml = MavenDependencyFinder.new(project_path).dependencies

      options = {
        'GroupTags' => { 'licenses' => 'license', 'dependencies' => 'dependency' },
        'ForceArray' => ['license', 'dependency']
      }
      dependencies = XmlSimple.xml_in(xml, options)["dependencies"]

      dependencies.map do |dep|
        MavenPackage.new(dep, logger: logger)
      end
    end

    def self.package_management_command
      "mvn"
    end

    private

    def package_path
      project_path.join('pom.xml')
    end
  end
end
