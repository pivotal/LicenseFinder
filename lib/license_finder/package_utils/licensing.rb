# frozen_string_literal: true

require 'license_finder/package_utils/activation'

module LicenseFinder
  Licensing = Struct.new(:package, :decided_licenses, :licenses_from_spec, :license_files) do
    # Implements the algorithm for choosing the right set of licenses from
    # among the various sources of licenses we know about.  In order of
    # priority, licenses come from decisions, package specs, or package files.
    def activations
      if activations_from_decisions.any? then activations_from_decisions
      elsif activations_from_spec.any?      then activations_from_spec
      elsif activations_from_files.any?     then activations_from_files
      else [default_activation]
      end
    end

    def activations_from_decisions
      @activations_from_decisions ||= decided_licenses
               .map { |license| Activation::FromDecision.new(package, license) }
    end

    def activations_from_spec
      @activations_from_spec ||= licenses_from_spec
               .map { |license| Activation::FromSpec.new(package, license) }
    end

    def activations_from_files
      @activations_from_files ||= license_files
               .group_by(&:license)
               .map { |license, files| Activation::FromFiles.new(package, license, files) }
    end

    def default_activation
      default_license = License.find_by_name nil
      Activation::None.new(package, default_license)
    end
  end
end
