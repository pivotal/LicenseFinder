require 'digest'

module LicenseFinder
  class DependencyManager
    attr_reader :logger

    def initialize options={}
      @logger = options[:logger] || LicenseFinder::Logger::Default.new
      @decisions = options[:decisions]
    end

    def decisions
      @decisions ||= Decisions.saved!
    end

    def manually_add(license, name, version)
      modifying do
        @decisions = decisions.
          add_package(name, version).
          license(name, license)
      end
    end

    def manually_remove(name)
      modifying do
        @decisions = decisions.remove_package(name)
      end
    end

    def license!(name, license_name)
      modifying do
        @decisions = decisions.license(name, license_name)
      end
    end

    def approve!(name, approver = nil, notes = nil)
      txn = {
        who: approver,
        why: notes,
        when: Time.now.getutc
      }
      modifying do
        @decisions = decisions.approve(name, txn)
      end
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

    def modifying
      yield
      decisions.save!
    end

    private

    def current_packages
      package_managers.
        map { |pm| pm.new(logger: logger) }.
        select(&:active?).
        map(&:current_packages).
        flatten
    end

    def package_managers
      [Bundler, NPM, Pip, Bower, Maven, Gradle, CocoaPods]
    end

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

