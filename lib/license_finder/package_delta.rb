# frozen_string_literal: true

module LicenseFinder
  class PackageDelta
    STATUSES = %i[added removed unchanged].freeze

    def initialize(status, current_package, previous_package)
      @status = status
      @current_package = current_package
      @previous_package = previous_package
    end

    def name
      pick_package.name
    end

    def version
      pick_package.version
    end

    def aggregate_paths
      pick_package.aggregate_paths
    end

    attr_reader :status

    def licenses
      pick_package.licenses
    end

    def merged_package?
      pick_package.class == MergedPackage
    end

    def method_missing(_method_name)
      nil
    end

    def self.added(package)
      new(:added, package, nil)
    end

    def self.removed(package)
      new(:removed, nil, package)
    end

    def self.unchanged(current_package, previous_package)
      new(:unchanged, current_package, previous_package)
    end

    def <=>(other)
      STATUSES.index(status) <=> STATUSES.index(other.status)
    end

    private

    def pick_package
      @current_package || @previous_package
    end
  end
end
