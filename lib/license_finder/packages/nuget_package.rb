module LicenseFinder
  class NugetPackage < Package
    def package_manager
      'Nuget'
    end
  end
end
