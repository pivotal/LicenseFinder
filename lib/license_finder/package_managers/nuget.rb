# frozen_string_literal: true

require 'rexml/document'
require 'zip'

module LicenseFinder
  class Nuget < PackageManager
    class Assembly
      attr_reader :name, :path

      def initialize(path, name)
        @path = path
        @name = name
      end

      def dependencies
        xml = REXML::Document.new(File.read(path.join('packages.config')))
        packages = REXML::XPath.match(xml, '//package')
        packages.map do |p|
          attrs = p.attributes
          Dependency.new(attrs['id'], attrs['version'], name)
        end
      end
    end

    Dependency = Struct.new(:name, :version, :assembly)

    def possible_package_paths
      path = project_path.join('vendor/*.nupkg')
      nuget_dir = Dir[path].map { |pkg| File.dirname(pkg) }.uniq

      # Presence of a .sln is a good indicator for a dotnet solution
      # cf.: https://docs.microsoft.com/en-us/nuget/tools/cli-ref-restore#remarks
      path = project_path.join('*.sln')
      solution_file = Dir[path].first

      possible_paths = [project_path.join('packages.config'), project_path.join('.nuget')]
      possible_paths.unshift(Pathname(solution_file)) unless solution_file.nil?
      possible_paths.unshift(Pathname(nuget_dir.first)) unless nuget_dir.empty?
      possible_paths
    end

    def assemblies
      Dir.glob(project_path.join('**', 'packages.config'), File::FNM_DOTMATCH).map do |d|
        path = Pathname.new(d).dirname
        name = path.basename.to_s
        Assembly.new path, name
      end
    end

    def current_packages
      dependencies.each_with_object({}) do |dep, memo|
        licenses = license_urls(dep)
        path = Dir.glob("#{Dir.home}/.nuget/packages/#{dep.name.downcase}/#{dep.version}").first

        memo[dep.name] ||= NugetPackage.new(dep.name, dep.version, spec_licenses: licenses, install_path: path)
        memo[dep.name].groups << dep.assembly unless memo[dep.name].groups.include? dep.assembly
      end.values
    end

    def license_urls(dep)
      files = Dir["**/#{dep.name}.#{dep.version}.nupkg"]
      return nil if files.empty?

      file = files.first
      Zip::File.open file do |zipfile|
        content = zipfile.read(dep.name + '.nuspec')
        Nuget.nuspec_license_urls(content)
      end
    end

    def dependencies
      assemblies.flat_map(&:dependencies)
    end

    def nuget_binary
      legacy_vcproj = Dir['**/*.vcproj'].any?

      if legacy_vcproj
        '/usr/local/bin/nugetv3.5.0.exe'
      else
        '/usr/local/bin/nuget.exe'
      end
    end

    def package_management_command
      return 'nuget' if LicenseFinder::Platform.windows?

      "mono #{nuget_binary}"
    end

    def prepare
      Dir.chdir(project_path) do
        cmd = prepare_command
        stdout, stderr, status = Cmd.run(cmd)
        return if status.success?

        log_errors stderr

        if stderr.include?('-PackagesDirectory')
          logger.info cmd, 'trying fallback prepare command', color: :magenta

          cmd = "#{cmd} -PackagesDirectory /#{Dir.home}/.nuget/packages"
          stdout, stderr, status = Cmd.run(cmd)
          return if status.success?

          log_errors_with_cmd(cmd, stderr)
        end

        error_message = "Prepare command '#{cmd}' failed\n#{stderr}"
        error_message += "\n#{stdout}\n" if !stdout.nil? && !stdout.empty?
        raise error_message unless @prepare_no_fail
      end
    end

    def prepare_command
      cmd = package_management_command
      sln_files = Dir['*.sln']
      cmds = []
      if sln_files.count > 1
        sln_files.each do |sln|
          cmds << "#{cmd} restore #{sln}"
        end
      else
        cmds << "#{cmd} restore"
      end

      cmds.join(' && ')
    end

    def installed?(logger = Core.default_logger)
      _stdout, _stderr, status = Cmd.run(nuget_check)
      if status.success?
        logger.debug self.class, 'is installed', color: :green
      else
        logger.info self.class, 'is not installed', color: :red
      end
      status.success?
    end

    def nuget_check
      return 'where nuget' if LicenseFinder::Platform.windows?

      "which mono && ls #{nuget_binary}"
    end

    def self.nuspec_license_urls(specfile_content)
      xml = REXML::Document.new(specfile_content)
      REXML::XPath.match(xml, '//metadata//licenseUrl')
                  .map(&:get_text)
                  .map(&:to_s)
    end
  end
end
