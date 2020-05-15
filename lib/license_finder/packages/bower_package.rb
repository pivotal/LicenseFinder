# frozen_string_literal: true

require 'open-uri'

module LicenseFinder
  class BowerPackage < Package
    def initialize(bower_module, options = {})
      spec = bower_module.fetch('pkgMeta', {})

      if spec.empty?
        endpoint = bower_module.fetch('endpoint', {})
        name = endpoint['name']
        version = endpoint['target']
      else
        name = spec['name']
        version = spec['version']
      end

      super(
        name,
        version,
        options.merge(
          summary: spec['description'],
          description: spec['readme'],
          homepage: spec['homepage'],
          spec_licenses: Package.license_names_from_standard_spec(spec),
          install_path: bower_module['canonicalDir'],
          missing: bower_module['missing']
        )
      )
    end

    def package_manager
      'Bower'
    end

    def package_url
      meta = JSON.parse(open("https://registry.bower.io/packages/#{CGI.escape(name)}").read)
      meta['url']
    end
  end
end
