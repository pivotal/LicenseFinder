module LicenseFinder
  module BundlerGroupManager
    def self.add_ignored_group(group)
      ignored_groups = LicenseFinder.config.ignore_groups.map(&:to_s)
      return if ignored_groups.include?(group)

      whitelist = LicenseFinder.config.whitelist
      ignored_groups << group
      File.open(Configuration.config_file_path, 'w') do |file|
        file.write({
          'whitelist' => whitelist,
          'ignore_groups' => ignored_groups
        }.to_yaml)
      end
    end
  end
end

