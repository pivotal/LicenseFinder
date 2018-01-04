module LicenseFinder
  class MixPackage < Package
    def package_manager
      'Mix'
    end
  end
end
