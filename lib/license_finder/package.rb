module LicenseFinder
  # Super-class that adapts data from different package management
  # systems (gems, npm, pip, etc.) to a common interface.
  #
  # For guidance on adding a new system use the shared behavior
  #     it_behaves_like "it conforms to interface required by PackageSaver"
  # and see BundlerPackage, PipPackage and NpmPackage
  class Package
    def self.extract_licenses_from_standard_spec(spec)
      licenses = spec["licenses"] || [spec["license"]].compact
      licenses.map do |license|
        if license.is_a? Hash
          license["type"]
        else
          license
        end
      end
    end

    def license
      @license ||= determine_license
    end

    private

    def determine_license
      licenses = (licenses_from_spec + license_from_files).uniq
      if licenses.length == 1
        licenses.first
      else
        default_license
      end
    end

    def licenses_from_spec
      license_names_from_spec.map do |name|
        License.find_by_name(name)
      end
    end

    def license_from_files
      license_files.map(&:license).compact
    end

    def license_files
      PossibleLicenseFiles.find(install_path)
    end

    def default_license
      License::Definitions.build_unrecognized "other", LicenseFinder.config.whitelist
    end
  end
end
