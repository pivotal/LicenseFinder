# frozen_string_literal: true

module LicenseFinder
  class ErlangmkPackage < Package
    def self.new_from_path(path)
      new("PACKAGE_NAME", "PACKAGE_VERSION", {})
    end

    def package_manager
      "Erlangmk"
    end
  end
end
