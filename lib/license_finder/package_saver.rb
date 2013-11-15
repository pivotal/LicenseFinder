require 'forwardable'

module LicenseFinder
  class PackageSaver
    extend Forwardable
    def_delegators :spec, :name, :version, :homepage
    def_delegators :package, :bundler_dependency, :license, :children, :groups, :summary, :description

    attr_reader :dependency, :package

    def self.find_or_create_by_name(package)
      dependency = Dependency.named(package.spec.name)
      new(dependency, package)
    end

    def self.save_all(packages)
      packages.map do |package|
        find_or_create_by_name(package).save
      end
    end

    def initialize(dependency, package)
      @package = package
      @dependency = dependency
    end

    def save
      DB.transaction do
        apply_dependency_definition
        sync_bundler_groups
        sync_children
        apply_better_license
      end
      dependency
    end

    private

    def spec
      package.spec
    end

    def apply_dependency_definition
      dependency.version = version.to_s
      dependency.summary = summary
      dependency.description = description
      dependency.homepage = homepage
      dependency.save_changes
    end

    def sync_bundler_groups
      saved_groups = dependency.bundler_groups
      current_groups = groups.map { |name| BundlerGroup.find_or_create(name: name.to_s) }

      remove, add = set_diff(saved_groups, current_groups)

      remove.each { |g| dependency.remove_bundler_group(g) }
      add.each { |g| dependency.add_bundler_group(g) }
    end

    def sync_children
      saved_children = dependency.children
      current_children = children.map { |name| Dependency.named(name) }

      remove, add = set_diff(saved_children, current_children)

      remove.each { |c| dependency.remove_child(c) }
      add.each { |c| dependency.add_child(c) }
    end

    def apply_better_license
      if !dependency.license_manual
        bundled_license = license
        if dependency.license.nil? || bundled_license != dependency.license.name
          dependency.license = LicenseAlias.find_or_create(name: bundled_license)
          dependency.save
        end
      end
    end

    private

    # Foreign method, belongs on Set
    #
    # Returns a pair of sets, which contain the elements that would have to be
    # removed from (and respectively added to) the first set in order to obtain
    # the second set.
    def set_diff(older, newer)
      return older - newer, newer - older
    end
  end
end
