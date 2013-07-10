module LicenseFinder
  module WhitelistManager
    def self.add_license(license)
      config = LicenseFinder.config
      return if config.whitelist.include?(license)

      config.whitelist << license
      config.save_to_yaml
    end

    def self.remove_license(license)
      config = LicenseFinder.config
      return unless config.whitelist.include?(license)

      config.whitelist.delete(license)
      config.save_to_yaml
    end
  end
end

