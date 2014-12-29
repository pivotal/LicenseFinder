module LicenseFinder
  class GradlePackage < Package
    def initialize(spec, options={})
      licenses = spec["license"].map { |l| l["name"] }
      _, name, version = spec["name"].split(":")
      super(name, version, options.merge(spec_licenses: licenses))
    end
  end
end
