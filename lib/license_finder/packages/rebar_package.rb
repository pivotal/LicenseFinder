# frozen_string_literal: true

module LicenseFinder
  class RebarPackage < Package
    def package_manager
      'Rebar'
    end

    def package_url
      "https://hex.pm/packages/#{name}/#{version}"
    end
  end
end
