module LicenseFinder
  class DecisionApplier
    def initialize(options)
      @decisions = options.fetch(:decisions)
      @acknowledged = apply_decisions(options.fetch(:packages))
    end

    attr_reader :acknowledged

    def unapproved
      acknowledged.reject(&:approved?)
    end

    def blacklisted
      acknowledged.select(&:blacklisted?)
    end

    private

    attr_reader :decisions

    def apply_decisions(system_packages)
      [].tap do |packages|
        all_packages = decisions.packages + system_packages
        all_packages.each do |_pkg|
          pkg = with_decided_licenses(_pkg)
          package = with_approval(pkg)
          next if ignored?(package)
          packages << package
        end
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

