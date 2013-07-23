module LicenseFinder
  class LicenseAlias < Sequel::Model
    def initialize(*args)
      super
      self.url = LicenseUrl.find_by_name name
    end

    def whitelisted?
      !!(config.whitelisted?(name))
    end

    def set_manually(name)
      new_url = LicenseUrl.find_by_name(name)
      update('name' => name, 'manual' => true, 'url' => new_url)
    end

    private

    def config
      LicenseFinder.config
    end
  end
end
