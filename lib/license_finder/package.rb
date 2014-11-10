module LicenseFinder
  # Super-class that adapts data from different package management
  # systems (gems, npm, pip, etc.) to a common interface.
  #
  # For guidance on adding a new system use the shared behavior
  #     it_behaves_like "it conforms to interface required by PackageSaver"
  # and see BundlerPackage, PipPackage and NpmPackage
  class Package
    attr_reader :logger

    def self.license_names_from_standard_spec(spec)
      licenses = spec["licenses"] || [spec["license"]].compact
      licenses = [licenses] unless licenses.is_a?(Array)
      licenses.map do |license|
        if license.is_a? Hash
          license["type"]
        else
          license
        end
      end
    end

    def initialize options={}
      @logger = options[:logger] || LicenseFinder::Logger::Default.new
    end

    def licenses
      @licenses ||= determine_license.to_set
    end

    def determine_license
      lfs = licenses_from_spec
      return lfs if lfs.any?

      lff = licenses_from_files
      return lff if lff.any?

      [default_license].to_set
    end

    def licenses_from_spec
      license_names_from_spec.map do |name|
        License.find_by_name(name).tap do |license|
          logger.license self.class, self.name, license.name, "from spec" if license
        end
      end.compact.to_set
    end

    def licenses_from_files
      license_files.map do |license_file|
        license_file.license.tap do |license|
          logger.license self.class, self.name, license.name, "from file '#{license_file.path}'" if license
        end
      end.compact.to_set
    end

    def license_files
      PossibleLicenseFiles.find(install_path)
    end

    def default_license
      License.find_by_name nil
    end

    def install_path
      nil
    end
  end
end
