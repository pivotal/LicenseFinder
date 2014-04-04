require "xmlsimple"

module LicenseFinder
  class Maven
    def self.current_packages
      `mvn license:download-licenses`

      xml = File.read('target/generated-resources/licenses.xml')

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
      File.exists?(package_path)
    end

    private

    def self.package_path
      Pathname.new('pom.xml').expand_path
    end
  end
end
