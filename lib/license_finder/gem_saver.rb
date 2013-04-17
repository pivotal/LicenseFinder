module LicenseFinder
  class GemSaver
    extend Forwardable
    def_delegators :spec, :name, :version, :summary, :description, :homepage
    def_delegators :bundled_gem, :bundler_dependency, :determine_license, :children

    def self.find_or_initialize_by_name(name, bundled_gem)
      dependency = Dependency.named(name)
      new(dependency, bundled_gem)
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

    attr_reader :dependency, :bundled_gem

    def spec
      bundled_gem.spec
    end

    def apply_dependency_definition
      dependency.version = version.to_s
      dependency.summary = summary
      dependency.description = description
      dependency.homepage = homepage
      dependency.license ||= LicenseAlias.create(name: determine_license)
      dependency.save
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
        dependency.add_child Dependency.named(child)
      end
    end

    def apply_better_license
      if dependency.license && !dependency.license.manual && determine_license != 'other'
        dependency.license.name = determine_license
        dependency.license.save
      end
    end
  end
end
