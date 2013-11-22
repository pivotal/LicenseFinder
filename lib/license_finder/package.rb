module LicenseFinder
  # Super-class that adapts data from different package management
  # systems (gems, npm, pip, etc.) to a common interface.
  #
  # For guidance on adding a new system use the shared behavior
  #     it_behaves_like "it conforms to interface required by PackageSaver"
  # and see GemPackage, PipPackage and NpmPackage
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
  end
end
