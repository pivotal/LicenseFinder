module LicenseFinder
  class MavenPackage < Package
    def initialize(mvn_dependency, options={})
      name = mvn_dependency["artifactId"]
      version = mvn_dependency["version"]
      licenses = mvn_dependency["licenses"].map { |l| l["name"] }
      super(name, version, options.merge(spec_licenses: licenses))
    end
  end
end
