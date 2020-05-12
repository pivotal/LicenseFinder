# frozen_string_literal: true

module LicenseFinder
  class ComposerPackage < Package
    def package_manager
      'Composer'
    end

    def package_url
      "https://packagist.org/packages/#{CGI.escape(name)}##{CGI.escape(version)}"
    end
  end
end
