# frozen_string_literal: true

module LicenseFinder
  class NugetPackage < Package
    def package_manager
      'Nuget'
    end

    def package_url
      "https://www.nuget.org/packages/#{URI.escape(name)}/#{URI.escape(version)}"
    end
  end
end
