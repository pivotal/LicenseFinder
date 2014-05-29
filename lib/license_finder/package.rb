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
      if licenses_from_spec.any?
        choose_license_from licenses_from_spec
      elsif licenses_from_files.any?
        choose_license_from licenses_from_files
      else
        default_license
      end
    end

    def choose_license_from licenses
      if ( licenses.uniq.size > 1 )
        License.find_by_name "multiple licenses: #{(licenses).map(&:name).uniq.join(', ')}"
      else
        licenses.first
      end
    end

    def licenses_from_spec
      license_names_from_spec.map do |name|
        License.find_by_name(name)
      end
    end

    def licenses_from_files
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
