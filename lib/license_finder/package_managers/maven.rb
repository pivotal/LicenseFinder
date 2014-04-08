require "xmlsimple"

module LicenseFinder
  class Maven
    def self.current_packages
      `mvn license:download-licenses`

      xml = license_report.read

      options = {
        'GroupTags' => { 'licenses' => 'license', 'dependencies' => 'dependency' },
        'ForceArray' => ['license', 'dependency']
      }
      dependencies = XmlSimple.xml_in(xml, options)["dependencies"]

      dependencies.map do |dep|
        MavenPackage.new(dep)
      end
    end

    def self.active?
      package_path.exist?
    end

    private

    def self.license_report
      Pathname.new('target/generated-resources/licenses.xml')
    end

    def self.package_path
      Pathname.new('pom.xml')
    end
  end
end
