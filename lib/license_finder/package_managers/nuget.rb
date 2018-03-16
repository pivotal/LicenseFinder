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

      possible_paths = [project_path.join('packages.config'), project_path.join('.nuget')]
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
        memo[dep.name] ||= NugetPackage.new(dep.name, dep.version, spec_licenses: licenses)
        memo[dep.name].groups << dep.assembly unless memo[dep.name].groups.include? dep.assembly
      end.values
    end

    def license_urls(dep)
      files = Dir["**/#{dep.name}.#{dep.version}.nupkg"]
      return nil if files.empty?
      file = files.first
      Zip::File.open file do |zipfile|
        content = zipfile.read(dep.name + '.nuspec')
        xml = REXML::Document.new(content)
        REXML::XPath.match(xml, '//metadata//licenseUrl').map(&:get_text).map(&:to_s)
      end
    end

    def dependencies
      assemblies.flat_map(&:dependencies)
    end
  end
end
