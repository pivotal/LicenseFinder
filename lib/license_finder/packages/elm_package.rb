# frozen_string_literal: true

module LicenseFinder
  class ElmPackage < Package
    attr_reader :author

    def self.from_elm_json(name, version, author, elm_json_content)
      new(name,
        version,
        author,
        spec_licenses: Package.license_names_from_standard_spec(elm_json_content),
        summary: elm_json_content['summary'],
      )
    end

    def initialize(name, version, author, options = {})
      @author = author
      super(name, version, options.merge(authors: [author]))
    end

    def package_manager
      'Elm'
    end

    def package_url
      "https://package.elm-lang.org/packages/#{CGI.escape(author)}/#{CGI.escape(name)}/#{CGI.escape(version)}"
    end
  end
end
