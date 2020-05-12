# frozen_string_literal: true

module LicenseFinder
  class RebarPackage < Package
    def package_manager
      'Rebar'
    end

    def package_url
      "https://hex.pm/packages/#{CGI.escape(name)}/#{CGI.escape(version)}"
    end
  end
end
