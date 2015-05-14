module LicenseFinder
  class Nuget < PackageManager
    def package_path
      project_path.join('packages')
    end
  end
end

