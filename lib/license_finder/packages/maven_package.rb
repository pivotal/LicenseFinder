# frozen_string_literal: true

module LicenseFinder
  class MavenPackage < Package
    def initialize(spec, options = {})
      name = spec['artifactId']
      name = "#{spec['groupId']}:#{name}" if options[:include_groups]
      @jar_file = spec['jarFile']

      super(
        name,
        spec['version'],
        options.merge(
          spec_licenses: Array(spec['licenses']).map { |l| l['name'] },
          groups: Array(spec['groupId']),
          summary: spec['summary'],
          description: spec['description'],
          homepage: spec['homepage']
        )
      )
    end

    def package_manager
      'Maven'
    end

    def package_url
      "https://search.maven.org/artifact/#{CGI.escape(groups.first)}/#{CGI.escape(name.split(':').last)}/#{CGI.escape(version)}/jar"
    end

    def license_files
      LicenseFiles.find(@jar_file, logger: logger)
    end

    def notice_files
      NoticeFiles.find(@jar_file, logger: logger)
    end
  end
end
