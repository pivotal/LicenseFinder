module LicenseFinder
  class MavenPackage < Package
    def initialize(spec, options = {})
      name = spec['artifactId']
      name = "#{spec['groupId']}:#{name}" if options[:include_groups]

      super(
        name,
        spec['version'],
        options.merge(
          spec_licenses: Array(spec['licenses']).map { |l| l['name'] }
        )
      )
    end

    def package_manager
      'Maven'
    end
  end
end
