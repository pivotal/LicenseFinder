module LicenseFinder
  # Super-class that adapts data from different package management
  # systems (gems, npm, pip, etc.) to a common interface.
  #
  # For guidance on adding a new system use the shared behavior
  #     it_behaves_like "it conforms to interface required by PackageSaver"
  # and see BundlerPackage, PipPackage and NpmPackage
  class Package
    def license
      @license ||= determine_license
    end

    private

    def determine_license
      license_from_spec || license_from_files || default_license
    end

    def license_from_files
      license_files.map(&:license).compact.first
    end

    def license_files
      PossibleLicenseFiles.find(install_path)
    end

    def default_license
      "other"
    end

    def extract_license_from_standard_spec(spec)
      license = spec.fetch("licenses", []).first

      if license.is_a? Hash
        license = license.fetch("type", nil)
      end

      if license.nil?
        license = spec.fetch("license", nil)

        if license.is_a? Hash
          license = license.fetch("type", nil)
        end
      end

      license
    end
  end
end
