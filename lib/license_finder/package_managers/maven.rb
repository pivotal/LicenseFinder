require "xmlsimple"
require_relative "maven_dependency_finder"

module LicenseFinder
  class Maven < PackageManager
    def current_packages
      command = "#{Maven::package_management_command} license:download-licenses"
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
          MavenPackage.new(dep, logger: logger)
        end
      end
      packages.uniq
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
