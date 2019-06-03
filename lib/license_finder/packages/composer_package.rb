# frozen_string_literal: true

module LicenseFinder
  class ComposerPackage < Package
    def package_manager
      'Composer'
    end
  end
end
