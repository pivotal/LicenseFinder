require 'xmlsimple'
require_relative 'gradle_dependency_finder'

module LicenseFinder
  class Gradle < PackageManager
    def initialize(options={})
      super
      @command = options[:gradle_command] || 'gradle'
    end

    def current_packages
      `#{@command} downloadLicenses`

      packages = []
      dependencies = GradleDependencyFinder.new(project_path).dependencies
      dependencies.each do |xml_file|
        options = {'GroupTags' => {'dependencies' => 'dependency'}}
        contents = XmlSimple.xml_in(xml_file, options).fetch('dependency', [])
        contents.map do |dep|
          packages << GradlePackage.new(dep, logger: logger)
        end
      end

      packages.uniq
    end

    private

    def package_path
      project_path.join('build.gradle')
    end
  end
end
