require "xmlsimple"

module LicenseFinder
  class Gradle
    def self.current_packages
      `gradle downloadLicenses`

      xml = license_report.read

      options = {
        'GroupTags' => { 'dependencies' => 'dependency' }
      }
      XmlSimple.xml_in(xml, options).fetch('dependency', []).map do |d|
        d["license"].reject! { |l| l["name"] == "No license found" }
        GradlePackage.new(d)
      end
    end

    def self.active?
      package_path.exist?
    end

    private

    def self.license_report
      Pathname.new('build/reports/license/dependency-license.xml')
    end

    def self.package_path
      Pathname.new('build.gradle')
    end
  end
end
