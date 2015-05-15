module LicenseFinder
  class Nuget < PackageManager
    def package_path
      project_path.join('packages')
    end

    def assemblies
      Dir[project_path.join("**", "packages.config")].map do |d|
        Pathname.new(d).dirname.basename.to_s
      end
    end
  end
end

