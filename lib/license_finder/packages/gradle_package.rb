# frozen_string_literal: true

module LicenseFinder
  class GradlePackage < Package
    def initialize(spec, options = {})
      name = spec['name']
      if name.scan(':').size >= 1
        group, name, version = name.split(':')
      else
        version = 'unknown'
      end

      name = options[:include_groups] ? "#{group}:#{name}" : name

      licenses = Array(spec['license'])
                 .map { |l| l['name'] }
                 .reject { |reject_name| reject_name == 'No license found' }

      super(name, version, options.merge(spec_licenses: licenses))
    end

    def package_manager
      'Gradle'
    end

    def package_url
      "https://plugins.gradle.org/plugin/#{CGI.escape(name)}/#{CGI.escape(version)}"
    end
  end
end
