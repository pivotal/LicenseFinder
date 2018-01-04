module LicenseFinder
  class YarnPackage < Package
    def package_manager
      'Yarn'
    end
  end
end
