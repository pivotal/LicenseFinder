module LicenseFinder
  class DecisionApplier
    def initialize(options)
      @decisions = options.fetch(:decisions)
      @all_packages = decisions.packages + options.fetch(:packages)
      @acknowledged = apply_decisions
    end

    attr_reader :acknowledged

    def unapproved
      acknowledged.reject(&:approved?)
    end

    def blacklisted
      acknowledged.select(&:blacklisted?)
    end

    def any_packages?
      all_packages.any?
    end

    private

    attr_reader :decisions, :all_packages

    def apply_decisions
      all_packages
        .map { |package| with_decided_licenses(package) }
        .map { |package| with_approval(package) }
        .reject { |package| ignored?(package) }
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

    def with_approval(package)
      if package.licenses.all? { |license| decisions.blacklisted?(license) }
        package.blacklisted!
      elsif decisions.approved?(package.name, package.version)
        package.approved_manually!(decisions.approval_of(package.name, package.version))
      elsif package.licenses.any? { |license| decisions.whitelisted?(license) }
        package.whitelisted!
      end
      package
    end
  end
end
