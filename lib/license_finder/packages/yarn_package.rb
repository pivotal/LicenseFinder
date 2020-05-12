# frozen_string_literal: true

module LicenseFinder
  class YarnPackage < Package
    def package_manager
      'Yarn'
    end

    def package_url
      "https://yarn.pm/#{name}"
    end
  end
end
