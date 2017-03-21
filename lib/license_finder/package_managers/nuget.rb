require "rexml/document"
require 'zip'

module LicenseFinder
  class Nuget < PackageManager
    def package_path
      path = project_path.join("vendor/*.nupkg")
      nuget_dir = Dir[path].map{|pkg| File.dirname(pkg)}.uniq
      if nuget_dir.length == 0
        path = project_path.join(".nuget")
        if File.directory?(path)
          path
        else
          project_path.join("packages")
        end
      else
        Pathname(nuget_dir.first)
      end
    end

    def assemblies
      Dir.glob(project_path.join("**", "packages.config"), File::FNM_DOTMATCH).map do |d|
        path = Pathname.new(d).dirname
        name = path.basename.to_s
        Assembly.new path, name
      end
    end

    def current_packages
      dependencies.reduce({}) do |memo, dep|
        licenses = license_urls(dep)
        memo[dep.name] ||= NugetPackage.new(dep.name, dep.version, spec_licenses: licenses)
        memo[dep.name].groups << dep.assembly if !memo[dep.name].groups.include? dep.assembly
        memo
      end.values
    end

    def license_urls dep
      files = Dir["**/#{dep.name}.#{dep.version}.nupkg"]
      return nil if files.empty?
      file = files.first
      Zip::File.open file do |zipfile|
        content = zipfile.read(dep.name + ".nuspec")
        xml = REXML::Document.new(content)
        REXML::XPath.match(xml,"//metadata//licenseUrl").map(&:get_text)
      end
    end

    def dependencies
      assemblies.flat_map(&:dependencies)
    end

    class Assembly
      attr_reader :name, :path
      def initialize(path, name)
        @path = path
        @name = name
      end

      def dependencies
        xml = REXML::Document.new(File.read(path.join("packages.config")))
        packages = REXML::XPath.match(xml, "//package")
        packages.map do |p|
          attrs = p.attributes
          Dependency.new(attrs["id"], attrs["version"], self.name)
        end
      end
    end

    class Dependency < Struct.new(:name, :version, :assembly)
    end
  end
end

