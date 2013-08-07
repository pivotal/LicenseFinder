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

    def self.save_packages(current_packages)
      current_packages.map do |package|
        PackageSaver.find_or_create_by_name(package).save
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
      if values_have_changed?
        dependency.version = version.to_s
        dependency.summary = summary
        dependency.description = description
        dependency.homepage = homepage
        dependency.save
      end
    end

    def values_have_changed?
      return dependency.version != version.to_s ||
        dependency.summary != summary ||
        dependency.description != description ||
        dependency.homepage != homepage
    end

    def sync_bundler_groups
      existing_groups = dependency.bundler_groups
      new_groups = groups.map(&:to_s)

      existing_groups.reverse.each do |group|
        unless new_groups.include?(group.name)
          dependency.remove_bundler_group(group)
        end
      end

      new_groups.each do |group|
        unless existing_groups.map(&:name).include? group
          dependency.add_bundler_group BundlerGroup.find_or_create(name: group)
        end
      end
    end

    def sync_children
      existing_children = dependency.children
      new_children = children

      existing_children.reverse.each do |child|
        unless new_children.include?(child.name)
          dependency.remove_child(child)
        end
      end

      new_children.each do |child|
        unless existing_children.map(&:name).include?(child)
          dependency.add_child Dependency.named(child)
        end
      end
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
  end
end
