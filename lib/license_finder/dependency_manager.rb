require 'digest'

module LicenseFinder
  class DependencyManager
    attr_reader :decisions

    def initialize options={}
      @decisions = options.fetch(:decisions)
      @current_packages = options.fetch(:current_packages)
    end

    def unapproved
      acknowledged.reject(&:approved?)
    end

    def acknowledged
      base_packages = decisions.packages + current_packages
      base_packages.
        map    { |package| with_decided_license(package) }.
        reject { |package| ignored?(package) }.
        map    { |package| with_approvals(package) }.
        tap    { |packages| invert_children(packages) }
    end

    private

    attr_reader :current_packages

    def with_decided_license(package)
      if license = decisions.license_of(package.name)
        package.decide_on_license license
      end
      package
    end

    def ignored?(package)
      decisions.ignored?(package.name) ||
        package.groups.any? { |group| decisions.ignored_group?(group) }
    end

    def with_approvals(package)
      if decisions.approved?(package.name)
        package.approved_manually!(decisions.approval_of(package.name))
      elsif package.licenses.any? { |license| decisions.approved_license?(license) }
        package.whitelisted!
      end
      package
    end

    def invert_children(packages)
      packages.each do |parent|
        parent.children.each do |child_name|
          child = packages.detect { |child| child.name == child_name }
          child.parents << parent if child
        end
      end
      packages
    end
  end
end

