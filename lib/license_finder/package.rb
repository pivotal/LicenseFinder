require 'license_finder/packages/licensing'
require 'license_finder/packages/license_files'

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
  # - otherwise, override #licenses_from_spec or #license_files
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
      @logger = options[:logger] || Core.default_logger

      ## DESCRIPTION
      @name = name
      @version = version
      @authors = options[:authors] || ""
      @summary = options[:summary] || ""
      @description = options[:description] || ""
      @homepage = options[:homepage] || ""
      @children = options[:children] || []
      @parents = Set.new # will be figured out later by package manager
      @groups = options[:groups] || []

      ## APPROVAL
      @whitelisted = false
      @blacklisted = false
      @manual_approval = nil

      ## LICENSING
      @license_names_from_spec = options[:spec_licenses] || []
      @install_path = options[:install_path]
      @missing = options[:missing] || false
      @decided_licenses = Set.new
    end

    ## DESCRIPTION

    attr_reader :name, :version, :authors,
                :summary, :description, :homepage,
                :children, :parents, :groups

    ## APPROVAL

    def approved_manually!(approval)
      @manual_approval = approval
    end

    def approved_manually?
      !@manual_approval.nil?
    end

    def approved?
      # Question: is `!blacklisted?` redundant?
      # DecisionApplier does not call `whitelisted!` or `approved_manually!`
      # if a Package has been blacklisted.
      (approved_manually? || whitelisted?) && !blacklisted?
    end

    def whitelisted!
      @whitelisted = true
    end

    def whitelisted?
      @whitelisted
    end

    def blacklisted!
      @blacklisted = true
    end

    def blacklisted?
      @blacklisted
    end

    attr_reader :manual_approval

    ## EQUALITY

    def <=>(other)
      eq_name = name <=> other.name
      return eq_name unless eq_name == 0
      version <=> other.version
    end

    def eql?(other)
      name == other.name && version == other.version
    end

    def hash
      [name,version].hash
    end

    ## LICENSING

    attr_reader :license_names_from_spec # stubbed in tests, otherwise private
    attr_reader :install_path # checked in tests, otherwise private

    def licenses
      @licenses ||= activations.map(&:license).to_set
    end

    def activations
      licensing.activations.tap do |activations|
        activations.each { |activation| logger.activation(activation) }
      end
    end

    def licensing
      Licensing.new(self, @decided_licenses, licenses_from_spec, license_files)
    end

    def decide_on_license(license)
      @decided_licenses << license
    end

    def licenses_from_spec
      license_names_from_spec
        .map { |name| License.find_by_name(name) }
        .to_set
    end

    def license_files
      LicenseFiles.find(install_path)
    end

    def package_manager
      "unknown"
    end

    def missing?
      @missing
    end
  end
end

require 'license_finder/packages/manual_package'
require 'license_finder/package_managers/bower_package'
require 'license_finder/package_managers/go_package'
require 'license_finder/package_managers/bundler_package'
require 'license_finder/package_managers/pip_package'
require 'license_finder/package_managers/npm_package'
require 'license_finder/package_managers/maven_package'
require 'license_finder/package_managers/gradle_package'
require 'license_finder/package_managers/cocoa_pods_package'
require 'license_finder/package_managers/rebar_package'
require 'license_finder/package_managers/merged_package'
require 'license_finder/package_managers/nuget_package'
