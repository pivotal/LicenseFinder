module LicenseFinder
  # Super-class that adapts data from different package management
  # systems (gems, npm, pip, etc.) to a common interface.
  #
  # For guidance on adding a new system use the shared behavior
  #
  #     it_behaves_like "a Package"
  #
  # Additional guidelines are:
  #
  # - if you're going to use Package#licenses ...
  #   - and the package spec will report licenses,
  #     pass :spec_licenses in the constructor options
  #   - and the package's files can be searched for licenses
  #     pass :install_path in the constructor options
  # - else
  #   - implement #licenses
  #
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

    def initialize(name, version = nil, options={})
      @logger = options[:logger] || LicenseFinder::Logger::Default.new

      @name = name
      @version = version
      @summary = options[:summary] || ""
      @description = options[:description] || ""
      @homepage = options[:homepage] || ""
      @children = options[:children] || []
      @parents = Set.new # will be figured out later by package manager
      @groups = options[:groups] || []

      ## APPROVAL
      @whitelisted = false
      @manual_approval = nil

      ## LICENSING
      @license_names_from_spec = options[:spec_licenses] || []
      @install_path = options[:install_path]
      @decided_licenses = Set.new
    end

    attr_reader :name, :version,
                :summary, :description, :homepage,
                :children, :parents, :groups

    ## APPROVAL

    def approved_manually!(approval)
      @manual_approval = approval
    end

    def whitelisted!
      @whitelisted = true
    end

    def approved?
      approved_manually? || whitelisted?
    end

    def approved_manually?
      !@manual_approval.nil?
    end

    def whitelisted?
      @whitelisted
    end

    attr_reader :manual_approval

    ## LICENSING

    attr_reader :license_names_from_spec # stubbed in tests, otherwise private
    attr_reader :install_path # checked in tests, otherwise private

    def licenses
      @licenses ||= determine_licenses.to_set
    end

    def determine_licenses
      dl = @decided_licenses
      return dl if dl.any?

      lfs = licenses_from_spec
      return lfs if lfs.any?

      lff = licenses_from_files
      return lff if lff.any?

      [default_license].to_set
    end

    def decide_on_license(license)
      @decided_licenses << license
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
  end
end

require 'license_finder/package_managers/manual_package'
require 'license_finder/package_managers/bower_package'
require 'license_finder/package_managers/bundler_package'
require 'license_finder/package_managers/pip_package'
require 'license_finder/package_managers/npm_package'
require 'license_finder/package_managers/maven_package'
require 'license_finder/package_managers/gradle_package'
require 'license_finder/package_managers/cocoa_pods_package'
