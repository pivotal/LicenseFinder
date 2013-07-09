module LicenseFinder
  module BundlerGroupManager
    def self.add_ignored_group(group)
      config = LicenseFinder.config
      ignored_groups = config.ignore_groups.map(&:to_s)
      return if ignored_groups.include?(group)

      config.ignore_groups << group.to_sym
      config.save_to_yaml
    end
  end
end

