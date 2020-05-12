# frozen_string_literal: true

module LicenseFinder
  class MavenPackage < Package
    def initialize(spec, options = {})
      name = spec['artifactId']
      name = "#{spec['groupId']}:#{name}" if options[:include_groups]

      super(
        name,
        spec['version'],
        options.merge(
          spec_licenses: Array(spec['licenses']).map { |l| l['name'] },
          groups: Array(spec['groupId'])
        )
      )
    end

    def package_manager
      'Maven'
    end

    def package_url
      "https://search.maven.org/artifact/#{URI.escape(groups.first)}/#{URI.escape(name.split(':').last)}/#{URI.escape(version)}/jar"
    end
  end
end
