# frozen_string_literal: true

module LicenseFinder
  class DecisionApplier
    def initialize(options)
      @decisions = options.fetch(:decisions)
      @all_packages = options.fetch(:packages).to_set + @decisions.packages.to_set
      @acknowledged = apply_decisions
    end

    attr_reader :acknowledged

    def unapproved
      acknowledged.reject(&:approved?)
    end

    def restricted
      acknowledged.select(&:restricted?)
    end

    def any_packages?
      all_packages.any?
    end

    private

    attr_reader :decisions, :all_packages

    def apply_decisions
      all_packages
        .reject { |package| ignored?(package) }
        .map do |package|
          with_homepage(
            with_approval(
              with_decided_licenses(package)
            )
          )
        end
    end

    def ignored?(package)
      decisions.ignored?(package.name) ||
        (package.groups.any? && package.groups.all? { |group| decisions.ignored_group?(group) })
    end

    def with_decided_licenses(package)
      decisions.licenses_of(package.name).each do |license|
        package.decide_on_license license
      end
      package
    end

    def with_homepage(package)
      homepage = decisions.homepage_of(package.name)
      package.homepage = homepage if homepage
      package
    end

    def with_approval(package)
      if package.licenses.all? { |license| decisions.restricted?(license) }
        package.restricted!
      elsif decisions.approved?(package.name, package.version)
        package.approved_manually!(decisions.approval_of(package.name, package.version))
      elsif package.licenses.any? { |license| decisions.permitted?(license) }
        package.permitted!
      end
      package
    end
  end
end
