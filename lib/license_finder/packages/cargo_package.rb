# frozen_string_literal: true

module LicenseFinder
  class CargoPackage < Package
    def initialize(crate, options = {})
      crate = crate.reject { |_, v| v.nil? || v == '' }
      children = crate.fetch('dependencies', []).map { |p| p['name'] }
      licenses = crate.fetch('license', '').split('/')
      super(
        crate['name'],
        crate['version'],
        options.merge(
          summary: crate.fetch('description', '').strip,
          spec_licenses: licenses.compact,
          children: children
        )
      )
    end

    def package_manager
      'Cargo'
    end

    def package_url
      "https://crates.io/crates/#{CGI.escape(name)}/#{CGI.escape(version)}"
    end
  end
end
