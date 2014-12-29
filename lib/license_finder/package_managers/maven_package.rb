module LicenseFinder
  class MavenPackage < Package
    def initialize(spec, options={})
      super(
        spec["artifactId"],
        spec["version"],
        options.merge(
          spec_licenses: Array(spec["licenses"]).map { |l| l["name"] }
        )
      )
    end
  end
end
