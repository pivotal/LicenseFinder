module LicenseFinder
  class GradlePackage < Package
    def initialize(spec, options={})
      name = spec["name"]
      if name.scan(":").size == 2
        _, name, version = name.split(":")
      else
        version = "unknown"
      end
      licenses = Array(spec["license"])
        .map { |l| l["name"] }
        .reject { |name| name == "No license found" }

      super(name, version, options.merge(spec_licenses: licenses))
    end
  end
end
