module LicenseFinder
  class MavenPackage < Package
    attr_reader :mvn_dependency

    def initialize(mvn_dependency, options={})
      name = mvn_dependency["artifactId"]
      version = mvn_dependency["version"]
      super name, version, options
      @mvn_dependency = mvn_dependency
    end

    def license_names_from_spec
      mvn_dependency["licenses"].map { |l| l["name"] }
    end
  end
end
