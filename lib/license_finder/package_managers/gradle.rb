require "xmlsimple"

module LicenseFinder
  class Gradle < PackageManager
    def initialize(options={})
      super
      @command = options[:gradle_command] || "gradle"
    end

    def current_packages
      `#{@command} downloadLicenses`

      xml = license_report.read

      options = {
        'GroupTags' => { 'dependencies' => 'dependency' }
      }
      dependencies = XmlSimple.xml_in(xml, options).fetch('dependency', [])

      dependencies.map do |dep|
        GradlePackage.new(dep, logger: logger)
      end
    end

    private

    def license_report
      project_path.join('build/reports/license/dependency-license.xml')
    end

    def package_path
      project_path.join('build.gradle')
    end
  end
end
