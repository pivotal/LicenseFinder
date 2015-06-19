module LicenseFinder
  class GradlePackage < Package
    def initialize(spec, options={})
      _, name, version = spec["name"].split(":")
      licenses = Array(spec["license"])
        .map { |l| l["name"] }
        .reject { |name| name == "No license found" }

      super(name, version, options.merge(spec_licenses: licenses))
    end

    def eql?(other)
      name == other.name && version == other.version
    end

    def hash
      name.hash + version.hash
    end
  end
end
