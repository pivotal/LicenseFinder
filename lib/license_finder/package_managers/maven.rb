require "xmlsimple"

module LicenseFinder
  class Maven < PackageManager
    def initialize(options={})
      super
      @include_groups = options[:maven_include_groups]
    end

    def current_packages
      command = 'mvn license:download-licenses'
      output, success = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{output}" unless success

      xml = license_report.read

      options = {
        'GroupTags' => { 'licenses' => 'license', 'dependencies' => 'dependency' },
        'ForceArray' => ['license', 'dependency']
      }
      dependencies = XmlSimple.xml_in(xml, options)["dependencies"]

      dependencies.map do |dep|
        MavenPackage.new(dep, logger: logger, include_groups: @include_groups)
      end
    end

    def self.package_management_command
      "mvn"
    end

    private

    def license_report
      project_path.join('target/generated-resources/licenses.xml')
    end

    def package_path
      project_path.join('pom.xml')
    end
  end
end
