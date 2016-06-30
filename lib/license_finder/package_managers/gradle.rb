require 'xmlsimple'
require 'with_env'
require_relative 'gradle_dependency_finder'

module LicenseFinder
  class Gradle < PackageManager
    def initialize(options={})
      super
      @command = options[:gradle_command] || 'gradle'
      @include_groups = options[:gradle_include_groups]
    end

    def current_packages
      WithEnv.with_env({"TERM" => "dumb"}) do
        command = "#{@command} downloadLicenses"
        output, success = Dir.chdir(project_path) { capture(command) }
        raise "Command '#{command}' failed to execute: #{output}" unless success

        dependencies = GradleDependencyFinder.new(project_path).dependencies
        packages = dependencies.flat_map do |xml_file|
          options = {'GroupTags' => {'dependencies' => 'dependency'}}
          contents = XmlSimple.xml_in(xml_file, options).fetch('dependency', [])
          contents.map do |dep|
            GradlePackage.new(dep, logger: logger, include_groups: @include_groups)
          end
        end
        packages.uniq
      end
    end

    def self.package_management_command
      "gradle"
    end

    private

    def package_path
      project_path.join('build.gradle')
    end
  end
end
