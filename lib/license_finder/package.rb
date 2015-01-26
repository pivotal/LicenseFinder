module LicenseFinder
  # Super-class that adapts data from different package management
  # systems (gems, npm, pip, etc.) to a common interface.
  #
  # Guidance on adding a new system
  #
  # - subclass Package, and initialize based on the data you receive from the
  #   package manager
  # - if the package specs will report license names, pass :spec_licenses in the
  #   constructor options
  # - if the package's files can be searched for licenses pass :install_path in
  #   the constructor options
  # - otherwise, override #licenses_from_spec, #license_files,
  #   #activations_from_spec or #activations_from_files
  #   - but do not override #activations, to maintain the decisions and
  #     defaulting behavior
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
      @missing = options[:missing] || false
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
      activations.each { |activation| activation.log(logger) }
      activations.map(&:license)
    end

    def activations
      afd = activations_from_decisions
      return afd if afd.any?

      afs = activations_from_spec
      return afs if afs.any?

      aff = activations_from_files
      return aff if aff.any?

      [Activation::None.new(self, default_license)]
    end

    def decide_on_license(license)
      @decided_licenses << license
    end

    def activations_from_decisions
      @decided_licenses
        .map { |license| Activation::FromDecision.new(self, license) }
    end

    def activations_from_spec
      licenses_from_spec
        .map { |license| Activation::FromSpec.new(self, license) }
    end

    def licenses_from_spec
      license_names_from_spec
        .map { |name| License.find_by_name(name) }
        .to_set
    end

    def activations_from_files
      license_files
        .group_by(&:license)
        .map { |license, files| Activation::FromFiles.new(self, license, files) }
    end

    def license_files
      LicenseFiles.find(install_path)
    end

    def default_license
      License.find_by_name nil
    end

    def missing?
      @missing
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
