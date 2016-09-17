module LicenseFinder
  class MavenPackage < Package
    def initialize(spec, options={})
      name = spec['artifactId']
      if options[:include_groups]
        name = "#{spec['groupId']}:#{name}"
      end

      super(
        name,
        spec["version"],
        options.merge(
          spec_licenses: Array(spec["licenses"]).map { |l| l["name"] }
        )
      )
    end

    def package_manager
      'Maven'
    end
  end
end
