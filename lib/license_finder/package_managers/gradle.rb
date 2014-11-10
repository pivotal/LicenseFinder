require "xmlsimple"

module LicenseFinder
  class Gradle < PackageManager
    def current_packages
      `#{LicenseFinder.config.gradle_command} downloadLicenses`

      xml = license_report.read

      options = {
        'GroupTags' => { 'dependencies' => 'dependency' }
      }
      XmlSimple.xml_in(xml, options).fetch('dependency', []).map do |dep|
        dep["license"].reject! { |l| l["name"] == "No license found" }
        GradlePackage.new(dep, logger: logger)
      end
    end

    private

    def license_report
      Pathname.new('build/reports/license/dependency-license.xml')
    end

    def package_path
      Pathname.new('build.gradle')
    end
  end
end
