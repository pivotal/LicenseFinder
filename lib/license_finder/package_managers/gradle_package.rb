module LicenseFinder
  class GradlePackage < Package
    def initialize(gradle_dependency, options={})
      licenses = gradle_dependency["license"].map { |l| l["name"] }
      _, name, version = gradle_dependency["name"].split(":")
      super(name, version, options.merge(spec_licenses: licenses))
    end
  end
end
