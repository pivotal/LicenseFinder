module LicenseFinder
  # Super-class that adapts data from different package management
  # systems (gems, npm, pip, etc.) to a common interface.
  #
  # For guidance on adding a new system use the shared behavior
  #     it_behaves_like "it conforms to interface required by PackageSaver"
  # and see BundlerPackage, PipPackage and NpmPackage
  class Package
    def self.license_names_from_standard_spec(spec)
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
      if one_license_from_spec?
        licenses_from_spec.first
      elsif no_licenses_from_spec? && one_license_from_files?
        license_from_files.first
      else
        default_license
      end
    end

    def one_license_from_spec?
      licenses_from_spec.uniq.size == 1
    end

    def one_license_from_files?
      license_from_files.uniq.size == 1
    end

    def no_licenses_from_spec?
      licenses_from_spec.uniq.size == 0
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
      License.find_by_name nil
    end
  end
end
