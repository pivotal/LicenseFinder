module LicenseFinder
  class BundledGemSaver
    extend Forwardable
    def_delegators :spec, :name, :version, :summary, :description, :homepage
    def_delegators :bundled_gem, :bundler_dependency, :license, :children

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
        refresh_bundler_groups
        refresh_children
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

    def refresh_bundler_groups
      dependency.remove_all_bundler_groups
      if bundler_dependency
        bundler_dependency.groups.each { |group|
          dependency.add_bundler_group BundlerGroup.find_or_create(name: group.to_s)
        }
      end
    end

    def refresh_children
      dependency.remove_all_children
      children.each do |child|
        if child_required?(child)
          dependency.add_child Dependency.named(child)
        end
      end
    end

    def child_required?(child)
      current_gem_names.include?(child)
    end

    def current_gem_names
      @current_gem_names ||= LicenseFinder.current_gems.map { |gem| gem.name.split(" ")[0] }
    end

    def apply_better_license
      if dependency.license && !dependency.license.manual && license != 'other'
        new_name = license
        unless new_name == dependency.license.name
          dependency.license.name = new_name
          dependency.license.save
        end
      end
    end
  end
end
