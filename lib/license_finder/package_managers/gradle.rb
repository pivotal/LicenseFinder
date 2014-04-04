require "xmlsimple"

module LicenseFinder
  class Gradle
    def self.current_packages
      `gradle downloadLicenses`

      xml = File.read('build/reports/license/dependency-license.xml')

      options = {
        'GroupTags' => { 'dependencies' => 'dependency' }
      }
      XmlSimple.xml_in(xml, options)["dependency"].map do |d|
        d["license"].reject! { |l| l["name"] == "No license found" }
        GradlePackage.new(d)
      end
    end

    def self.active?
      File.exists?(package_path)
    end

    private

    def self.package_path
      Pathname.new('build.gradle').expand_path
    end
  end
end
