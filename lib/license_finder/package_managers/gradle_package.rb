module LicenseFinder
  class GradlePackage < Package
    def initialize(spec, options={})
      _, name, version = spec["name"].split(":")
      super(
        name,
        version,
        options.merge(
          spec_licenses: Array(spec["license"]).map { |l| l["name"] }
        )
      )
    end
  end
end
