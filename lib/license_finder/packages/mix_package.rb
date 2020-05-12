# frozen_string_literal: true

module LicenseFinder
  class MixPackage < Package
    def package_manager
      'Mix'
    end

    def package_url
      "https://hex.pm/packages/#{URI.escape(name)}/#{URI.escape(version)}"
    end
  end
end
