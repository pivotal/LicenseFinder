require 'license_finder/packages/activation'

module LicenseFinder
  # Licensing implements the algorithm for choosing the right set of licenses
  # from among the various sources of licenses we know about.  In order of
  # priority, licenses come from decisions, package specs, or package files.
  Licensing = Struct.new(:package, :decided_licenses, :licenses_from_spec, :license_files) do
    def activations
      afd = activations_from_decisions
      return afd if afd.any?

      afs = activations_from_spec
      return afs if afs.any?

      aff = activations_from_files
      return aff if aff.any?

      [default_activation]
    end

    def activations_from_decisions
      decided_licenses
        .map { |license| Activation::FromDecision.new(package, license) }
    end

    def activations_from_spec
      licenses_from_spec
        .map { |license| Activation::FromSpec.new(package, license) }
    end

    def activations_from_files
      license_files
        .group_by(&:license)
        .map { |license, files| Activation::FromFiles.new(package, license, files) }
    end

    def default_activation
      default_license = License.find_by_name nil
      Activation::None.new(package, default_license)
    end
  end
end
