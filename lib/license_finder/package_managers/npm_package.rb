module LicenseFinder
  class NpmPackage < Package
    def package_manager
      'Npm'
    end
  end
end
