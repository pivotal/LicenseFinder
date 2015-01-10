module LicenseFinder
  class DecisionApplier
    def initialize(options)
      @decisions = options.fetch(:decisions)
      @system_packages = options.fetch(:packages)
    end

    def unapproved
      acknowledged.reject(&:approved?)
    end

    def acknowledged
      packages.reject { |package| ignored?(package) }
    end

    private

    attr_reader :system_packages, :decisions

    def packages
      result = decisions.packages + system_packages
      result
        .map { |package| with_decided_licenses(package) }
        .map { |package| with_approval(package) }
    end

    def ignored?(package)
      decisions.ignored?(package.name) ||
        package.groups.any? { |group| decisions.ignored_group?(group) }
    end

    def with_decided_licenses(package)
      decisions.licenses_of(package.name).each do |license|
        package.decide_on_license license
      end
      package
    end

    def with_approval(package)
      if package.licenses.all? { |license| decisions.blacklisted?(license) }
        # do not approve; could mark package.blacklisted! if needed for reports
      elsif decisions.approved?(package.name)
        package.approved_manually!(decisions.approval_of(package.name))
      elsif package.licenses.any? { |license| decisions.whitelisted?(license) }
        package.whitelisted!
      end
      package
    end
  end
end

