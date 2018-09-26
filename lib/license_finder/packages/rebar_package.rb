# frozen_string_literal: true

module LicenseFinder
  class RebarPackage < Package
    def package_manager
      'Rebar'
    end
  end
end
