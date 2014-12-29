module LicenseFinder
  class GradlePackage < Package
    def initialize(gradle_dependency, options={})
      @gradle_dependency = gradle_dependency
      _, name, version = @gradle_dependency["name"].split(":")
      super name, version, options
    end

    def license_names_from_spec
      @gradle_dependency["license"].map { |l| l["name"] }
    end
  end
end
