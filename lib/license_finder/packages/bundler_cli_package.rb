# frozen_string_literal: true

module LicenseFinder
  class BundlerCLIPackage < Package
    def initialize(spec, _options = {})
      children = spec.dependencies.map(&:name)
      found_licenses = ['unknown']
      found_licenses = spec.licenses unless spec.licenses.empty?

      super(
        spec.name,
        spec.version.to_s,
        {
          authors: Array(spec.authors).join(', '),
          summary: spec.summary,
          description: spec.description,
          homepage: spec.homepage,
          children: children,
          spec_licenses: found_licenses,
          install_path: spec.full_gem_path
        }
      )
    end

    def package_manager
      'Bundler CLI'
    end

    def package_url
      "https://rubygems.org/gems/#{CGI.escape(name)}/versions/#{CGI.escape(version)}"
    end
  end
end
