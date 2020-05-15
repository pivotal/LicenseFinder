# frozen_string_literal: true

module LicenseFinder
  class BundlerPackage < Package
    def initialize(spec, bundler_def, options = {})
      children = spec.dependencies.map(&:name)
      groups = Array(bundler_def && bundler_def.groups).map(&:to_s)

      super(
        spec.name,
        spec.version.to_s,
        options.merge(
          authors: Array(spec.authors).join(', '),
          summary: spec.summary,
          description: spec.description,
          homepage: spec.homepage,
          children: children,
          groups: groups,
          spec_licenses: spec.licenses,
          install_path: spec.full_gem_path
        )
      )
    end

    def package_manager
      'Bundler'
    end

    def package_url
      "https://rubygems.org/gems/#{CGI.escape(name)}/versions/#{CGI.escape(version)}"
    end
  end
end
