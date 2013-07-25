module LicenseFinder
  class BundledGemSaver
    extend Forwardable
    def_delegators :spec, :name, :version, :summary, :description, :homepage
    def_delegators :bundled_gem, :bundler_dependency, :license, :children, :groups

    attr_reader :dependency, :bundled_gem

    def self.find_or_create_by_name(bundled_gem)
      dependency = Dependency.named(bundled_gem.spec.name)
      new(dependency, bundled_gem)
    end

    def self.save_gems(current_gems)
      current_gems.map do |bundled_gem|
        BundledGemSaver.find_or_create_by_name(bundled_gem).save
      end
    end

    def initialize(dependency, bundled_gem)
      @bundled_gem = bundled_gem
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
      bundled_gem.spec
    end

    def apply_dependency_definition
      if values_have_changed?
        dependency.version = version.to_s
        dependency.summary = summary
        dependency.description = description
        dependency.homepage = homepage
        dependency.license ||= LicenseAlias.create(name: license)
        dependency.save
      end
    end

    def values_have_changed?
      return dependency.version != version.to_s ||
        dependency.summary != summary ||
        dependency.description != description ||
        dependency.homepage != homepage ||
        dependency.license.name != license
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
      if dependency.license && !dependency.license.manual
        new_name = license
        unless new_name == dependency.license.name
          dependency.license.name = new_name
          dependency.license.save
        end
      end
    end
  end
end
