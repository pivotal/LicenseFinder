require 'xmlsimple'
require 'with_env'
require 'license_finder/package_utils/gradle_dependency_finder'

module LicenseFinder
  class Gradle < PackageManager
    def initialize(options = {})
      super
      @command = options[:gradle_command] || package_management_command
      @include_groups = options[:gradle_include_groups]
    end

    def current_packages
      WithEnv.with_env('TERM' => 'dumb') do
        command = "#{@command} downloadLicenses"
        _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
        raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

        dependencies = GradleDependencyFinder.new(project_path).dependencies
        packages = dependencies.flat_map do |xml_file|
          options = { 'GroupTags' => { 'dependencies' => 'dependency' } }
          contents = XmlSimple.xml_in(xml_file, options).fetch('dependency', [])
          contents.map do |dep|
            GradlePackage.new(dep, logger: logger, include_groups: @include_groups)
          end
        end
        packages.uniq
      end
    end

    def package_management_command
      if Platform.windows?
        wrapper = 'gradlew.bat'
        gradle = 'gradle.bat'
      else
        wrapper = './gradlew'
        gradle = 'gradle'
      end

      File.exist?(File.join(project_path, wrapper)) ? wrapper : gradle
    end

    private

    def detected_package_path
      alternate_build_file = build_file_from_settings(project_path)
      return alternate_build_file if alternate_build_file

      project_path.join('build.gradle')
    end

    def build_file_from_settings(project_path)
      settings_gradle_path = project_path.join 'settings.gradle'

      return nil unless File.exist? settings_gradle_path

      settings_gradle = File.read settings_gradle_path

      match = /rootProject.buildFileName = ['"](?<build_file>.*)['"]/.match settings_gradle

      return nil unless match

      project_path.join match[:build_file]
    end
  end
end
