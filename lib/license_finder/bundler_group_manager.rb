module LicenseFinder
  module BundlerGroupManager
    def self.add_ignored_group(group)
      config = LicenseFinder.config
      ignored_groups = config.ignore_groups
      return if ignored_groups.include?(group)

      config.ignore_groups << group
      config.save_to_yaml
    end

    def self.remove_ignored_group(group)
      config = LicenseFinder.config
      ignored_groups = config.ignore_groups
      return unless ignored_groups.include?(group)

      config.ignore_groups.delete(group)
      config.save_to_yaml
    end
  end
end

