# frozen_string_literal: true

module LicenseFinder
  class PNPMPackage < Package
    def package_manager
      'PNPM'
    end

    def package_url
      "https://www.npmjs.com/package/#{CGI.escape(name)}/v/#{CGI.escape(version)}"
    end
  end
end
